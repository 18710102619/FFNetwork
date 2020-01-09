//
//  YCGNetworkManager.h
//  ChameleonFramework
//
//  Created by 张玲玉 on 2019/8/12.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#define YCGNetwork [YCGNetworkManager sharedManager]

typedef NS_OPTIONS(NSUInteger, YCGNetworkResultType) {
    YCGNetworkResultSuccess = 0,  //请求成功
    YCGNetworkResultFail,         //请求失败
    YCGNetworkResultError         //网络异常
};

typedef void (^YCGNetworkResultBlock)(NSURLSessionDataTask * _Nullable task,
                                      YCGNetworkResultType resultType,
                                      id _Nullable responseData,
                                      NSInteger code,
                                      NSString *message);

@interface YCGNetworkManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - 基础功能

- (void)request:(NSString *)url params:(nullable id)params result:(YCGNetworkResultBlock)result;
- (void)GET:(NSString *)url params:(nullable id)params result:(YCGNetworkResultBlock)result;
- (void)POST:(NSString *)url params:(nullable id)params result:(YCGNetworkResultBlock)result;

#pragma mark - 网络缓存

- (void)GET:(NSString *)url params:(nullable id)params cacheInterval:(NSTimeInterval)seconds result:(YCGNetworkResultBlock)result;
- (void)POST:(NSString *)url params:(nullable id)params cacheInterval:(NSTimeInterval)seconds result:(YCGNetworkResultBlock)result;

@end


