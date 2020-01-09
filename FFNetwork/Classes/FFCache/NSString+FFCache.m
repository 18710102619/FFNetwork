//
//  NSString+FFCache.m
//  ChameleonFramework
//
//  Created by 张玲玉 on 2019/8/23.
//

#import "NSString+FFCache.h"
#import<CommonCrypto/CommonDigest.h>

@implementation NSString (FFCache)

- (NSString *)md5_32bit_String
{
    const char *input=[self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", result[i]];
    }
    return md5String;
}

- (NSString *)appendParamsString:(NSDictionary *)params
{
    if (![params isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    NSMutableString *URL=[NSMutableString stringWithString:self];
    NSArray *keys=[params allKeys];
    for (int i = 0; i < keys.count; i++){
        NSString *item;
        if (i == 0) {
            item = [NSString stringWithFormat:@"?%@=%@", keys[i], params[keys[i]]];
        }
        else{
            item = [NSString stringWithFormat:@"&%@=%@", keys[i], params[keys[i]]];
        }
        [URL appendString:item];
    }
    return URL;
}

@end
