//
//  FFCache.m
//  FFKit
//
//  Created by 张玲玉 on 2018/8/9.
//

#import "FFCache.h"


@implementation FFCacheModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeObject:@(self.seconds) forKey:@"seconds"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if (self) {
        self.data=[aDecoder decodeObjectForKey:@"data"];
        self.version=[aDecoder decodeObjectForKey:@"version"];
        self.seconds=[[aDecoder decodeObjectForKey:@"seconds"]doubleValue];
    }
    return self;
}

@end

@implementation FFCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _diskCache = [[FFDiskCache alloc]init];
    }
    return self;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key
{
    [_diskCache setObject:object forKey:key];
}

- (id<NSCoding>)objectForKey:(NSString *)key
{
    id<NSCoding> object = [_diskCache objectForKey:key];
    return object;
}

- (void)removeObjectForKey:(NSString *)key
{
    [_diskCache removeDataForKey:key];
}

@end
