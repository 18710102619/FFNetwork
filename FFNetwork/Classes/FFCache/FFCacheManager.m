//
//  FFCacheManager.m
//  AFNetworking
//
//  Created by 张玲玉 on 2018/8/23.
//

#import "FFCacheManager.h"
#import "FFCache.h"

@implementation FFCacheManager

#pragma mark - 基础功能

+ (void)cacheData:(id)data key:(NSString *)key
{
    FFCacheModel *model=[[FFCacheModel alloc]init];
    model.data=data;
    model.version=[self getVersion];
    model.seconds=time(NULL);
    FFCache *cache=[[FFCache alloc] init];
    [cache setObject:model forKey:key];
}

+ (id)getCacheData:(NSString *)key
{
    FFCache *cache = [[FFCache alloc]init];
    FFCacheModel *model = (FFCacheModel *)[cache objectForKey:key];
    if (model && ![model.version isEqualToString:[self getVersion]]) {
        [cache removeObjectForKey:key];
        return nil;
    }
    return model.data;
}

+ (id)getCacheData:(NSString *)key cacheInterval:(NSTimeInterval)seconds
{
    FFCache *cache = [[FFCache alloc]init];
    FFCacheModel *model = (FFCacheModel *)[cache objectForKey:key];
    if (model && ![model.version isEqualToString:[self getVersion]]) {
        [cache removeObjectForKey:key];
        return nil;
    }
    NSTimeInterval nowSeconds = time(NULL);
    double T=nowSeconds - model.seconds;
    if (model && T <= seconds) {
        return model.data;
    }
    return  nil;
}

#pragma mark - 辅助功能

+ (NSString *)getVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (double)getDiskCacheSize
{
    FFCache *cache=[[FFCache alloc]init];
    double size=[cache.diskCache getCacheSize];
    size=size/1024.0/1024.0;//单位(兆M)
    return size;
}

+ (void)clearDiskCache
{
    FFCache *cache=[[FFCache alloc]init];
    [cache.diskCache clearCache];
}

@end
