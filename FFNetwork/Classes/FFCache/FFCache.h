//
//  FFCache.h
//  FFKit
//
//  Created by 张玲玉 on 2018/8/9.
//

#import <Foundation/Foundation.h>
#import "FFDiskCache.h"

@interface FFCacheModel : NSObject<NSCoding>

@property(nonatomic,copy)NSString *version;
@property(nonatomic,strong)NSDictionary *data;
@property(nonatomic,assign)NSTimeInterval seconds;

@end

@interface FFCache : NSObject

@property(strong,readonly)FFDiskCache *diskCache;

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;

- (id<NSCoding>)objectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

@end
