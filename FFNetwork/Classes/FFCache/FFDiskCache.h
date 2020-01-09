//
//  FFDiskCache.h
//  FFKit
//
//  Created by 张玲玉 on 2018/8/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FFDiskCacheType) {
    FFDiskCacheTypeDB = 0,
    FFDiskCacheTypeFile
};

@interface FFDiskCache : NSObject

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
- (id<NSCoding>)objectForKey:(NSString *)key;
- (void)removeDataForKey:(NSString *)key;
- (NSUInteger)getCacheSize;
- (void)clearCache;

@end
