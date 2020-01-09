//
//  FFFileCache.h
//  FFKit
//
//  Created by 张玲玉 on 2018/9/19.
//

#import <Foundation/Foundation.h>

@interface FFFileCache : NSObject

- (instancetype)initWithPath:(NSString *)path;

- (void)setData:(NSData *)data forKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (void)removeDataForKey:(NSString *)key;

@end
