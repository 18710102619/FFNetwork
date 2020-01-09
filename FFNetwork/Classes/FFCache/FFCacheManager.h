//
//  FFCacheManager.h
//  AFNetworking
//
//  Created by 张玲玉 on 2018/8/23.
//

#import <Foundation/Foundation.h>

@interface FFCacheManager : NSObject

#pragma mark - 基础功能

/**
 缓存数据

 @param data 缓存数据
 @param key 缓存key
 */
+ (void)cacheData:(id)data key:(NSString *)key;

/**
 获取缓存数据

 @param key 缓存key
 @return 缓存数据
 */
+ (id)getCacheData:(NSString *)key;

/**
 获取有效缓存数据
 
 @param key 缓存key
 @param seconds 有效期
 @return 缓存数据
 */
+ (NSDictionary *)getCacheData:(NSString *)key cacheInterval:(NSTimeInterval)seconds;

#pragma mark - 辅助功能

/**
 获取当前版本号

 @return 前版本号
 */
+ (NSString *)getVersion;

/**
 获取磁盘缓存大小

 @return (单位：兆M)
 */
+ (double)getDiskCacheSize;

/**
 清空磁盘缓存
 */
+ (void)clearDiskCache;

@end
