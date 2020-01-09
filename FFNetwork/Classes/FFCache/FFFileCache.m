//
//  FFFileCache.m
//  FFKit
//
//  Created by 张玲玉 on 2018/9/19.
//

#import "FFFileCache.h"
#import "NSString+FFCache.h"

@interface FFFileCache ()

@property(nonatomic,copy)NSString *path;

@end

@implementation FFFileCache

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path=path;
    }
    return self;
}

- (void)setData:(NSData *)data forKey:(NSString *)key;
{
    NSString *file=[self.path stringByAppendingPathComponent:key.md5_32bit_String];
    [data writeToFile:file atomically:NO];
}

- (NSData *)dataForKey:(NSString *)key
{
    NSString *file=[self.path stringByAppendingPathComponent:key.md5_32bit_String];
    NSData *data = [NSData dataWithContentsOfFile:file];
    return data;
}

- (void)removeDataForKey:(NSString *)key
{
    NSString *file=[self.path stringByAppendingPathComponent :key.md5_32bit_String];
    [[NSFileManager defaultManager] removeItemAtPath:file error:NULL];
}

@end
