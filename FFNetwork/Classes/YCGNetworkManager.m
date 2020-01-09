//
//  YCGNetworkManager.m
//  ChameleonFramework
//
//  Created by 张玲玉 on 2019/8/12.
//

#import "YCGNetworkManager.h"
#import "FFCacheManager.h"
#import "NSString+FFCache.h"

@interface YCGNetworkManager ()

@property(nonatomic,strong)AFHTTPSessionManager *manager;

@end

@implementation YCGNetworkManager

+ (instancetype)sharedManager
{
    static YCGNetworkManager *_shared = nil;
    static dispatch_once_t _once;
    dispatch_once(&_once, ^{
        _shared = [[self alloc] init];
        [self forbidCache];
    });
    return _shared;
}

+ (void)forbidCache
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

- (AFHTTPSessionManager *)manager
{
    if (_manager==nil) {
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;//数据需要从原始地址加载。不使用现有缓存。
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.requestSerializer.timeoutInterval = 30;
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
    }
    return _manager;
}

#pragma mark - 基础功能

- (void)request:(NSString *)url params:(nullable id)params result:(YCGNetworkResultBlock)result
{
    url=[url appendParamsString:params];
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];//对中文进行转码
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval=3;//秒
    NSURLSessionDataTask *task=[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            result(task,YCGNetworkResultSuccess,data,0,nil);
        }
        else {
            [self handleFailure:result task:task error:error];
        }
    }];
    [task resume];
}

- (void)GET:(NSString *)url params:(nullable id)params result:(YCGNetworkResultBlock)result
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    if (params) {
        [dict addEntriesFromDictionary:params];
    }
    if (![[dict allKeys] containsObject:@"version"]) {
        [dict setValue:@"1.0" forKey:@"version"];
    }

    [self.manager GET:url
                  parameters:dict
                    progress:^(NSProgress * _Nonnull downloadProgress) {}
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:result task:task responseObject:responseObject];
    }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleFailure:result task:task error:error];
    }];
}

- (void)POST:(NSString *)url params:(nullable id)params result:(YCGNetworkResultBlock)result
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    if (params) {
        [dict addEntriesFromDictionary:params];
    }
    if (![[dict allKeys] containsObject:@"version"]) {
        [dict setValue:@"1.0" forKey:@"version"];
    }

    [self.manager POST:url
                  parameters:dict
                    progress:^(NSProgress * _Nonnull downloadProgress) {}
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleSuccess:result task:task responseObject:responseObject];
    }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleFailure:result task:task error:error];
    }];
}

- (void)handleSuccess:(YCGNetworkResultBlock)result task:(NSURLSessionDataTask * )task responseObject:(id)responseObject
{
    if (!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
        if (result) {
            result(task,YCGNetworkResultFail,nil,0,nil);
        }
    }
    NSData *data=[responseObject objectForKey:@"data"];
    NSInteger code=[[responseObject objectForKey:@"code"] integerValue];
    NSString *message=[responseObject objectForKey:@"msg"];
    if (result) {
        if (code==200) {
            result(task,YCGNetworkResultSuccess,data,code,message);
        }
        else {
            result(task,YCGNetworkResultFail,data,code,message);
        }
    }
}

- (void)handleFailure:(YCGNetworkResultBlock)result task:(NSURLSessionDataTask * )task error:(NSError *)error
{
    NSInteger code = error.code;
    NSString *message = error.userInfo[@"NSLocalizedDescription"];
    if (message.length==0) {
        message=[self getMessage:code];
    }
    if (result) {
        message=[message stringByReplacingOccurrencesOfString:@"。" withString:@""];
        result(task,YCGNetworkResultError,nil,code,message);
    }
}

- (NSString *)getMessage:(NSInteger)code
{
    NSString *message;
    switch (code) {
        case 500: {
            message = @"服务器异常！";
        }
            break;
        case -1001: {
            message = @"网络请求超时，请稍后重试！";
        }
            break;
        case -1002: {
            message = @"不支持的URL！";
        }
            break;
        case -1003: {
            message = @"未能找到指定的服务器！";
        }
            break;
        case -1004: {
            message = @"服务器连接失败！";
        }
            break;
        case -1005: {
            message = @"连接丢失，请稍后重试！";
        }
            break;
        case -1009: {
            message = @"互联网连接似乎是离线！";
        }
            break;
        case -1012: {
            message = @"操作无法完成！";
        }
            break;
        default: {
            message = @"网络异常，请稍后再试！";
        }
            break;
    }
    return message;
}

#pragma mark - 网络缓存

- (void)GET:(NSString *)url params:(nullable id)params cacheInterval:(NSTimeInterval)seconds result:(YCGNetworkResultBlock)result
{
    NSString *key=[url appendParamsString:params];
    if (seconds==0) {
        [self getServiceData:url params:params cacheKey:key result:result];
    }
    else {
        NSDictionary *data=[FFCacheManager getCacheData:key cacheInterval:seconds];
        if (data!=nil) {
            result(nil,YCGNetworkResultSuccess,data,200,@"成功");
        }
        else {
            [self getServiceData:url params:params cacheKey:key result:result];
        }
    }
}

- (void)POST:(NSString *)url params:(nullable id)params cacheInterval:(NSTimeInterval)seconds result:(YCGNetworkResultBlock)result
{
    NSString *key=[url appendParamsString:params];
    if (seconds==0) {
        [self getServiceData:url params:params cacheKey:key result:result];
    }
    else {
        NSDictionary *data=[FFCacheManager getCacheData:key cacheInterval:seconds];
        if (data!=nil) {
            result(nil,YCGNetworkResultSuccess,data,200,@"成功");
        }
        else {
            [self getServiceData:url params:params cacheKey:key result:result];
        }
    }
}

- (void)getServiceData:(NSString *)url
                params:(NSDictionary *)params
              cacheKey:(NSString *)key
                result:(YCGNetworkResultBlock)result
{
    [YCGNetwork GET:url params:params result:^(NSURLSessionDataTask * _Nullable task, YCGNetworkResultType resultType, id responseData, NSInteger code, NSString *message) {
        switch (resultType) {
            case YCGNetworkResultSuccess:
            {
                [FFCacheManager cacheData:responseData key:key];
            }
                break;
            case YCGNetworkResultFail:
            case YCGNetworkResultError:
            {
                NSData *data=[FFCacheManager getCacheData:key];
                if (data) {
                    responseData=data;
                    resultType=YCGNetworkResultSuccess;
                }
            }
                break;
        }
        result(task,resultType,responseData,code,message);
    }];
}

- (void)postServiceData:(NSString *)url
                 params:(NSDictionary *)params
               cacheKey:(NSString *)key
                 result:(YCGNetworkResultBlock)result
{
    [YCGNetwork POST:url params:params result:^(NSURLSessionDataTask * _Nullable task, YCGNetworkResultType resultType, id  _Nullable responseData, NSInteger code, NSString *message) {
        switch (resultType) {
            case YCGNetworkResultSuccess:
            {
                [FFCacheManager cacheData:responseData key:key];
            }
                break;
            case YCGNetworkResultError:
            {
                NSData *data=[FFCacheManager getCacheData:key];
                if (data) {
                    responseData=data;
                    resultType=YCGNetworkResultSuccess;
                }
            }
                break;
        }
        result(task,resultType,responseData,code,message);
    }];
}

@end
