//
//  NSString+FFCache.h
//  ChameleonFramework
//
//  Created by 张玲玉 on 2019/8/23.
//

#import <Foundation/Foundation.h>

@interface NSString (FFCache)

@property(nonatomic,copy,readonly)NSString *md5_32bit_String;

- (NSString *)appendParamsString:(NSDictionary *)params;

@end


