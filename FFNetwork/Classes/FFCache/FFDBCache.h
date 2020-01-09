//
//  FFDBCache.h
//  FFKit
//
//  Created by 张玲玉 on 2018/8/30.
//

#import <Foundation/Foundation.h>
#import "FFBaseDB.h"
#import "FFDiskCache.h"

@interface FFDBCacheModel : NSObject

@property(nonatomic,copy)NSString *key;
@property(nonatomic,assign)double size;
@property(nonatomic,strong)NSData *data;
@property(nonatomic,assign)FFDiskCacheType type;
@property(nonatomic,copy)NSString *version;
@property(nonatomic,copy)NSString *createTime;

@end

@interface FFDBCache : FFBaseDB

- (instancetype)initWithPath:(NSString *)path;
- (void)setData:(NSData *)data forKey:(NSString *)key cacheType:(FFDiskCacheType)type;
- (FFDBCacheModel *)dataForKey:(NSString *)key;
- (void)removeDataForKey:(NSString *)key;
- (NSUInteger)getSumSize;

@end
