//
//  FFDiskCache.m
//  FFKit
//
//  Created by 张玲玉 on 2018/8/9.
//

#import "FFDiskCache.h"
#import "FFFileCache.h"
#import "FFDBCache.h"
#import <CommonCrypto/CommonDigest.h>

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

@interface FFDiskCache ()

@property(nonatomic,copy)NSString *diskPath;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,copy)NSString *dbPath;

@property(nonatomic,strong)FFFileCache *fileCache;
@property(nonatomic,strong)FFDBCache *dbCache;

@end

@implementation FFDiskCache {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fileCache=[[FFFileCache alloc]initWithPath:self.filePath];
        _dbCache=[[FFDBCache alloc]initWithPath:self.dbPath];
        _lock=dispatch_semaphore_create(1);
        _queue=dispatch_queue_create("com.zly.diskCache", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma - mark Handle Object

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key
{
    NSData *data = nil;
    @try {
        data = [NSKeyedArchiver archivedDataWithRootObject:object];
    }
    @catch (NSException *exception) {
        
    }
    __weak typeof(self) weakSelf=self;
    dispatch_async(_queue, ^{
        __strong typeof(weakSelf) strongSelf=weakSelf;
        Lock();
        [strongSelf setData:data forKey:key];
        Unlock();
    });
}

- (id<NSCoding>)objectForKey:(NSString *)key
{
    Lock();
    NSData *data=[self dataForKey:key];
    Unlock();
    
    id object=nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        
    }
    return object;
}

- (void)removeObjectForKey:(NSString *)key
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        Lock();
        [strongSelf removeDataForKey:key];
        Unlock();
    });
}

#pragma - mark Handle Data

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    FFDiskCacheType cacheType=FFDiskCacheTypeDB;
    /*当单条数据小于 20K 时，数据越小 SQLite 读取性能越高；单条数据大于 20K 时，直接写为文件速度会更快一些。*/
    if (data.length>=1024*2) {
        cacheType=FFDiskCacheTypeFile;
    }
    if (cacheType==FFDiskCacheTypeFile) {
        [_fileCache setData:data forKey:key];
    }
    [_dbCache setData:data forKey:key cacheType:cacheType];
}

- (NSData *)dataForKey:(NSString *)key
{
    NSData *data=nil;
    FFDBCacheModel *dbCacheModel=[_dbCache dataForKey:key];
    if (dbCacheModel) {
        if (dbCacheModel.type==FFDiskCacheTypeFile) {
            data=[_fileCache dataForKey:key];
            if (!data) {
                [_dbCache removeDataForKey:key];
            }
        }
        else {
            data=dbCacheModel.data;
        }
    }
    return data;
}

- (void)removeDataForKey:(NSString *)key
{
    FFDBCacheModel *dbCacheModel=[_dbCache dataForKey:key];
    if (dbCacheModel) {
        if (dbCacheModel.type==FFDiskCacheTypeFile) {
            [_fileCache removeDataForKey:key];
        }
        [_dbCache removeDataForKey:key];
    }
}

#pragma - mark Path

- (NSString *)diskPath
{
    if (_diskPath==nil) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *diskPath = [path stringByAppendingPathComponent:@"YCGDiskCache"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        BOOL isExisted = [fileManager fileExistsAtPath:diskPath isDirectory:&isDirectory];
        if (!(isDirectory && isExisted)) {
            [fileManager createDirectoryAtPath:diskPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _diskPath=diskPath;
    }
    return _diskPath;
}

- (NSString *)filePath
{
    if (_filePath==nil) {
        NSString *filePath = [self.diskPath stringByAppendingPathComponent:@"FileCache"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        BOOL isExisted = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (!(isDirectory && isExisted)) {
            [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _filePath=filePath;
    }
    return _filePath;
}

- (NSString *)dbPath
{
    if (_dbPath==nil) {
        _dbPath = [self.diskPath stringByAppendingPathComponent:@"DBCache.db"];
    }
    return _dbPath;
}

- (NSUInteger)getCacheSize
{
    return [_dbCache getSumSize];
}

- (void)clearCache
{
    [[NSFileManager defaultManager] removeItemAtPath:self.diskPath error:nil];
}

@end
