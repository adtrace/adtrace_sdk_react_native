
#import "ADTLinkResolution.h"

static NSUInteger kMaxRecursions = 10;

@interface ADTLinkResolutionDelegate : NSObject<NSURLSessionTaskDelegate>

+ (nonnull ADTLinkResolutionDelegate *)sharedInstance;

+ (nullable NSURL *)convertUrlToHttps:(nullable NSURL *)url;

@end

@implementation ADTLinkResolutionDelegate

- (nonnull instancetype)init {
    self = [super init];

    return self;
}

+ (nonnull ADTLinkResolutionDelegate *)sharedInstance {
    static ADTLinkResolutionDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                     willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                                     newRequest:(NSURLRequest *)request
                              completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    NSURL *_Nullable convertedUrl = [ADTLinkResolutionDelegate convertUrlToHttps:request.URL];

    if (request.URL != nil && convertedUrl != nil && ! [request.URL isEqual:convertedUrl]) {
        completionHandler([ADTLinkResolutionDelegate replaceUrlWithRequest:request
                                                              urlToReplace:convertedUrl]);
    } else {
        completionHandler(request);
    }
}

+ (nullable NSURL *)convertUrlToHttps:(nullable NSURL *)url {
    if (url == nil) {
        return nil;
    }

    if (! [url.absoluteString hasPrefix:@"http:"]) {
        return url;
    }

    NSString *_Nonnull urlStringWithoutPrefix = [url.absoluteString substringFromIndex:5];

    return [NSURL URLWithString:
                [NSString stringWithFormat:@"https:%@", urlStringWithoutPrefix]];
}

+ (NSURLRequest *)replaceUrlWithRequest:(NSURLRequest *)request
                           urlToReplace:(nonnull NSURL *)urlToReplace
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];

    [mutableRequest setURL:urlToReplace];

    return [mutableRequest copy];
}

@end

@implementation ADTLinkResolution

+ (void)resolveLinkWithUrl:(nonnull NSURL *)url
     resolveUrlSuffixArray:(nullable NSArray<NSString *> *)resolveUrlSuffixArray
                  callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback
{
    if (callback == nil) {
        return;
    }

    if (url == nil) {
        callback(nil);
        return;
    }

    if (! [ADTLinkResolution urlMatchesSuffixWithHost:url.host
                                          suffixArray:resolveUrlSuffixArray])
    {
        callback(url);
        return;
    }

    ADTLinkResolutionDelegate *_Nonnull linkResolutionDelegate =
        [ADTLinkResolutionDelegate sharedInstance];

    NSURLSession *_Nonnull session =
        [NSURLSession
            sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration
            delegate:linkResolutionDelegate
            delegateQueue:nil];

    NSURL *_Nullable httpsUrl = [ADTLinkResolutionDelegate convertUrlToHttps:url];

    NSURLSessionDataTask *task =
        [session
            dataTaskWithURL:httpsUrl
            completionHandler:
                ^(NSData * _Nullable data,
                  NSURLResponse * _Nullable response,
                  NSError * _Nullable error)
            {
                // bootstrap the recursion of resolving the link
                [ADTLinkResolution
                    resolveLinkWithResponseUrl:response != nil ? response.URL : nil
                    previousUrl:httpsUrl
                    recursionNumber:0
                    session:session
                    callback:callback];
            }];
    [task resume];
}

+ (void)resolveLinkWithResponseUrl:(nullable NSURL *)responseUrl
                       previousUrl:(nullable NSURL *)previousUrl
                   recursionNumber:(NSUInteger)recursionNumber
                           session:(nonnull NSURLSession *)session
                          callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback
{
    // return (possible nil) previous url when the current one does not exist
    if (responseUrl == nil) {
        callback(previousUrl);
        return;
    }

    // return found url with expected host
    if ([ADTLinkResolution isTerminalUrlWithHost:responseUrl.host]) {
        callback(responseUrl);
        return;
    }

    // return previous (non-nil) url when it reached the max number of recursive tries
    if (recursionNumber >= kMaxRecursions) {
        callback(responseUrl);
        return;
    }

    // when found a non expected url host, use it to recursively resolve the link
    NSURLSessionDataTask *task =
        [session
            dataTaskWithURL:responseUrl
            completionHandler:
                ^(NSData * _Nullable data,
                  NSURLResponse * _Nullable response,
                  NSError * _Nullable error)
         {
            [ADTLinkResolution resolveLinkWithResponseUrl:response != nil ? response.URL : nil
                                              previousUrl:responseUrl
                                          recursionNumber:(recursionNumber + 1)
                                                  session:session
                                                 callback:callback];
        }];
    [task resume];
}

+ (BOOL)isTerminalUrlWithHost:(nullable NSString *)urlHost {
    if (urlHost == nil) {
        return NO;
    }

    NSArray<NSString *> *_Nonnull terminalUrlHostSuffixArray =
        @[@"adtrace.io", @"adt.st", @"go.link"];

    return [ADTLinkResolution urlMatchesSuffixWithHost:urlHost
                                           suffixArray:terminalUrlHostSuffixArray];
}

+ (BOOL)urlMatchesSuffixWithHost:(nullable NSString *)urlHost
                     suffixArray:(nullable NSArray<NSString *> *)suffixArray
{
    if (urlHost == nil) {
        return NO;
    }

    if (suffixArray == nil) {
        return NO;
    }

    for (NSString *_Nonnull expectedHostSuffix in suffixArray) {
        if ([urlHost hasSuffix:expectedHostSuffix]) {
            return YES;
        }
    }

    return NO;
}

@end
