//
//  ADTUtil.m
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#include <math.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <sys/xattr.h>

#import <objc/message.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>

#import <UIKit/UIKit.h>

#import "ADTUtil.h"
#import "ADTLogger.h"
#import "ADTResponseData.h"
#import "ADTAdtraceFactory.h"
#import "NSString+ADTAdditions.h"

#if !ADTRACE_NO_IDFA
#import <AdSupport/ASIdentifierManager.h>
#endif

#if !ADTRACE_NO_IAD && !TARGET_OS_TV
#import <iAd/iAd.h>
#endif

static NSString *userAgent = nil;
static NSRegularExpression *universalLinkRegex = nil;
static NSNumberFormatter *secondsNumberFormatter = nil;
static NSRegularExpression *optionalRedirectRegex = nil;
static NSRegularExpression *shortUniversalLinkRegex = nil;
static NSRegularExpression *excludedDeeplinkRegex = nil;

static NSString * const kClientSdk                  = @"ios4.29.6";
static NSString * const kDeeplinkParam              = @"deep_link=";
static NSString * const kSchemeDelimiter            = @"://";
static NSString * const kDefaultScheme              = @"AdtraceUniversalScheme";
static NSString * const kUniversalLinkPattern       = @"https://[^.]*\\.ulink\\.adtrace\\.com/ulink/?(.*)";
static NSString * const kOptionalRedirectPattern    = @"adtrace_redirect=[^&#]*";
static NSString * const kShortUniversalLinkPattern  = @"http[s]?://[a-z0-9]{4}\\.adt\\.st/?(.*)";
static NSString * const kExcludedDeeplinksPattern   = @"^(fb|vk)[0-9]{5,}[^:]*://authorize.*access_token=.*";
static NSString * const kDateFormat                 = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z";

@implementation ADTUtil

+ (void)initialize {
    if (self != [ADTUtil class]) {
        return;
    }

    [self initializeUniversalLinkRegex];
    [self initializeSecondsNumberFormatter];
    [self initializeShortUniversalLinkRegex];
    [self initializeOptionalRedirectRegex];
    [self initializeExcludedDeeplinkRegex];
}

+ (void)teardown {
    universalLinkRegex = nil;
    secondsNumberFormatter = nil;
    optionalRedirectRegex = nil;
    shortUniversalLinkRegex = nil;
}

+ (void)initializeUniversalLinkRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kUniversalLinkPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADTUtil isNotNull:error]) {
        [ADTAdtraceFactory.logger error:@"Universal link regex rule error (%@)", [error description]];
        return;
    }
    universalLinkRegex = regex;
}

+ (void)initializeShortUniversalLinkRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kShortUniversalLinkPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADTUtil isNotNull:error]) {
        [ADTAdtraceFactory.logger error:@"Short Universal link regex rule error (%@)", [error description]];
        return;
    }
    shortUniversalLinkRegex = regex;
}

+ (void)initializeOptionalRedirectRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kOptionalRedirectPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADTUtil isNotNull:error]) {
        [ADTAdtraceFactory.logger error:@"Optional redirect regex rule error (%@)", [error description]];
        return;
    }
    optionalRedirectRegex = regex;
}

+ (void)initializeExcludedDeeplinkRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kExcludedDeeplinksPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADTUtil isNotNull:error]) {
        [ADTAdtraceFactory.logger error:@"Excluded deep link regex rule error (%@)", [error description]];
        return;
    }
    excludedDeeplinkRegex = regex;
}

+ (void)initializeSecondsNumberFormatter {
    secondsNumberFormatter = [[NSNumberFormatter alloc] init];
    [secondsNumberFormatter setPositiveFormat:@"0.0"];
}

+ (void)updateUrlSessionConfiguration:(ADTConfig *)config {
    userAgent = config.userAgent;
}

+ (NSString *)clientSdk {
    return kClientSdk;
}

+ (NSDateFormatter *)getDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    [dateFormatter setDateFormat:kDateFormat];

    Class class = NSClassFromString([NSString adtJoin:@"N", @"S", @"locale", nil]);
    if (class != nil) {
        NSString *keyLwli = [NSString adtJoin:@"locale", @"with", @"locale", @"identifier:", nil];
        SEL selLwli = NSSelectorFromString(keyLwli);
        if ([class respondsToSelector:selLwli]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id loc = [class performSelector:selLwli withObject:@"en_US"];
            [dateFormatter setLocale:loc];
#pragma clang diagnostic pop
        }
    }

    return dateFormatter;
}

// Inspired by https://gist.github.com/kevinbarrett/2002382
+ (void)excludeFromBackup:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    id<ADTLogger> logger = ADTAdtraceFactory.logger;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    if (&NSURLIsExcludedFromBackupKey == nil) {
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result != 0) {
            [logger debug:@"Failed to exclude '%@' from backup", url.lastPathComponent];
        }
    } else { // iOS 5.0 and higher
        // First try and remove the extended attribute if it is present
        ssize_t result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                [logger debug:@"Removed extended attribute on file '%@'", url];
            }
        }

        // Set the new key
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES]
                                      forKey:NSURLIsExcludedFromBackupKey
                                       error:&error];
        if (!success || error != nil) {
            [logger debug:@"Failed to exclude '%@' from backup (%@)", url.lastPathComponent, error.localizedDescription];
        }
    }
#pragma clang diagnostic pop
}

+ (NSString *)formatSeconds1970:(double)value {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];
    return [self formatDate:date];
}

+ (NSString *)formatDate:(NSDate *)value {
    NSDateFormatter *dateFormatter = [ADTUtil getDateFormatter];
    if (dateFormatter == nil) {
        return nil;
    }
    return [dateFormatter stringFromDate:value];
}

+ (id)readObject:(NSString *)fileName
      objectName:(NSString *)objectName
           class:(Class)classToRead
      syncObject:(id)syncObject {
#if TARGET_OS_TV
    return nil;
#endif
    @synchronized(syncObject) {
        NSString *documentsFilePath = [ADTUtil getFilePathInDocumentsDir:fileName];
        NSString *appSupportFilePath = [ADTUtil getFilePathInAppSupportDir:fileName];

        // Try to read from Application Support directory first.
        @try {
            id appSupportObject;
            if (@available(iOS 11.0, tvOS 11.0, *)) {
                NSData *data = [NSData dataWithContentsOfFile:appSupportFilePath];
                // API introduced in iOS 11.
                NSError *errorUnarchiver = nil;
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data
                                                                                            error:&errorUnarchiver];
                if (errorUnarchiver == nil) {
                    [unarchiver setRequiresSecureCoding:NO];
                    appSupportObject = [unarchiver decodeObjectOfClass:classToRead forKey:NSKeyedArchiveRootObjectKey];
                } else {
                    // TODO: try to make this error fit the logging flow; if not, remove it
                    // [[ADTAdtraceFactory logger] debug:@"Failed to read %@ with error: %@", objectName, errorUnarchiver.localizedDescription];
                }
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // API_DEPRECATED [2.0-12.0]
                // "Use +unarchivedObjectOfClass:fromData:error: instead"
                appSupportObject = [NSKeyedUnarchiver unarchiveObjectWithFile:appSupportFilePath];
#pragma clang diagnostic pop
            }

            if (appSupportObject != nil) {
                if ([appSupportObject isKindOfClass:classToRead]) {
                    // Successfully read object from Application Support folder, return it.
                    if ([appSupportObject isKindOfClass:[NSArray class]]) {
                        [[ADTAdtraceFactory logger] debug:@"Package handler read %d packages", [appSupportObject count]];
                    } else {
                        [[ADTAdtraceFactory logger] debug:@"Read %@: %@", objectName, appSupportObject];
                    }

                    // Just in case check if old file exists in Documents folder and if yes, remove it.
                    [ADTUtil deleteFileInPath:documentsFilePath];

                    return appSupportObject;
                }
            } else {
                // [[ADTAdtraceFactory logger] error:@"Failed to read %@ file", appSupportFilePath];
                [[ADTAdtraceFactory logger] debug:@"File %@ not found in \"Application Support/Adtrace\" folder", fileName];
            }
        } @catch (NSException *ex) {
            // [[ADTAdtraceFactory logger] error:@"Failed to read %@ file  (%@)", appSupportFilePath, ex];
            [[ADTAdtraceFactory logger] error:@"Failed to read %@ file from \"Application Support/Adtrace\" folder (%@)", fileName, ex];
        }

        // If in here, for some reason, reading of file from Application Support folder failed.
        // Let's check the Documents folder.
        @try {
            id documentsObject;
            if (@available(iOS 11.0, tvOS 11.0, *)) {
                NSData *data = [NSData dataWithContentsOfFile:documentsFilePath];
                // API introduced in iOS 11.
                NSError *errorUnarchiver = nil;
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data
                                                                                            error:&errorUnarchiver];
                if (errorUnarchiver == nil) {
                    [unarchiver setRequiresSecureCoding:NO];
                    documentsObject = [unarchiver decodeObjectOfClass:classToRead forKey:NSKeyedArchiveRootObjectKey];
                } else {
                    // TODO: try to make this error fit the logging flow; if not, remove it
                    // [[ADTAdtraceFactory logger] debug:@"Failed to read %@ with error: %@", objectName, errorUnarchiver.localizedDescription];
                }
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // API_DEPRECATED [2.0-12.0]
                // "Use +unarchivedObjectOfClass:fromData:error: instead"
                documentsObject = [NSKeyedUnarchiver unarchiveObjectWithFile:documentsFilePath];
#pragma clang diagnostic pop
            }

            if (documentsObject != nil) {
                // Successfully read object from Documents folder.
                if ([documentsObject isKindOfClass:[NSArray class]]) {
                    [[ADTAdtraceFactory logger] debug:@"Package handler read %d packages", [documentsObject count]];
                } else {
                    [[ADTAdtraceFactory logger] debug:@"Read %@: %@", objectName, documentsObject];
                }

                // Do the file migration.
                [[ADTAdtraceFactory logger] verbose:@"Migrating %@ file from Documents to \"Application Support/Adtrace\" folder", fileName];
                [ADTUtil migrateFileFromPath:documentsFilePath toPath:appSupportFilePath];

                return documentsObject;
            } else {
                // [[ADTAdtraceFactory logger] error:@"Failed to read %@ file", documentsFilePath];
                [[ADTAdtraceFactory logger] debug:@"File %@ not found in Documents folder", fileName];
            }
        } @catch (NSException *ex) {
            // [[ADTAdtraceFactory logger] error:@"Failed to read %@ file (%@)", documentsFilePath, ex];
            [[ADTAdtraceFactory logger] error:@"Failed to read %@ file from Documents folder (%@)", fileName, ex];
        }

        return nil;
    }
}

+ (void)writeObject:(id)object
           fileName:(NSString *)fileName
         objectName:(NSString *)objectName
         syncObject:(id)syncObject {
#if TARGET_OS_TV
    return;
#endif
    @synchronized(syncObject) {
        @try {
            BOOL result;
            NSString *filePath = [ADTUtil getFilePathInAppSupportDir:fileName];
            if (!filePath) {
                [[ADTAdtraceFactory logger] error:@"Cannot get filepath from filename: %@, to write %@ file", fileName, objectName];
                return;
            }

            if (@available(iOS 11.0, tvOS 11.0, *)) {
                NSError *errorArchiving = nil;
                // API introduced in iOS 11.
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:&errorArchiving];
                if (data && errorArchiving == nil) {
                    NSError *errorWriting = nil;
                    result = [data writeToFile:filePath options:NSDataWritingAtomic error:&errorWriting];
                    result = result && (errorWriting == nil);
                } else {
                    result = NO;
                }
            } else {
                // API_DEPRECATED [2.0-12.0]
                // Use +archivedDataWithRootObject:requiringSecureCoding:error: and -writeToURL:options:error: instead
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                result = [NSKeyedArchiver archiveRootObject:object toFile:filePath];
#pragma clang diagnostic pop
            }
            if (result == YES) {
                [ADTUtil excludeFromBackup:filePath];
                if ([object isKindOfClass:[NSArray class]]) {
                    [[ADTAdtraceFactory logger] debug:@"Package handler wrote %d packages", [object count]];
                } else {
                    [[ADTAdtraceFactory logger] debug:@"Wrote %@: %@", objectName, object];
                }
            } else {
                [[ADTAdtraceFactory logger] error:@"Failed to write %@ file", objectName];
            }
        } @catch (NSException *exception) {
            [[ADTAdtraceFactory logger] error:@"Failed to write %@ file (%@)", objectName, exception];
        }
    }
}

+ (BOOL)migrateFileFromPath:(NSString *)oldPath toPath:(NSString *)newPath {
    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    Class class = NSClassFromString([NSString adtJoin:@"N", @"S", @"file", @"manager", nil]);
    if (class == nil) {
        return NO;
    }
    NSString *keyDm = [NSString adtJoin:@"default", @"manager", nil];
    SEL selDm = NSSelectorFromString(keyDm);
    if (![class respondsToSelector:selDm]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id man = [class performSelector:selDm];
#pragma clang diagnostic pop
    NSString *keyCpy = [NSString stringWithFormat:@"%@%@%@",
                        [NSString adtJoin:@"copy", @"item", @"at", @"path", @":", nil],
                        [NSString adtJoin:@"to", @"path", @":", nil],
                        [NSString adtJoin:@"error", @":", nil]];
    SEL selCpy = NSSelectorFromString(keyCpy);
    if (![man respondsToSelector:selCpy]) {
        return NO;
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selCpy]];
    [inv setSelector:selCpy];
    [inv setTarget:man];
    [inv setArgument:&oldPath atIndex:2];
    [inv setArgument:&newPath atIndex:3];
    [inv setArgument:&errorPointer atIndex:4];
    [inv invoke];

    if (error != nil) {
        [[ADTAdtraceFactory logger] error:@"Error while copying from %@ to %@", oldPath, newPath];
        [[ADTAdtraceFactory logger] error:[error description]];
        return NO;
    }
    // Migration successful.
    return YES;
}

+ (NSString *)getFilePathInDocumentsDir:(NSString *)fileName {
    // Documents directory exists by default inside app bundle, no need to check for it's presence.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSString *)getFilePathInAppSupportDir:(NSString *)fileName {
    // Application Support directory doesn't exist by default inside app bundle.
    // All Adtrace files are going to be stored in Adtrace sub-directory inside Application Support directory.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDir = [paths firstObject];
    NSString *adtraceDirName = @"Adtrace";
    if (![ADTUtil checkForDirectoryPresenceInPath:appSupportDir forFolder:[appSupportDir lastPathComponent]]) {
        return nil;
    }
    NSString *adtraceDir = [appSupportDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", adtraceDirName]];
    if (![ADTUtil checkForDirectoryPresenceInPath:adtraceDir forFolder:adtraceDirName]) {
        return nil;
    }
    NSString *filePath = [adtraceDir stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (BOOL)checkForDirectoryPresenceInPath:(NSString *)path forFolder:(NSString *)folderName {
    // Check for presence of directory first.
    // If it doesn't exist, make one.
    Class class = NSClassFromString([NSString adtJoin:@"N", @"S", @"file", @"manager", nil]);
    if (class == nil) {
        return NO;
    }
    NSString *keyDm = [NSString adtJoin:@"default", @"manager", nil];
    SEL selDm = NSSelectorFromString(keyDm);
    if (![class respondsToSelector:selDm]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id man = [class performSelector:selDm];
#pragma clang diagnostic pop
    NSString *keyExi = [NSString adtJoin:@"file", @"exists", @"at", @"path", @":", nil];
    SEL selExi = NSSelectorFromString(keyExi);
    if (![man respondsToSelector:selExi]) {
        return NO;
    }
    
    NSInvocation *invMan = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selExi]];
    [invMan setSelector:selExi];
    [invMan setTarget:man];
    [invMan setArgument:&path atIndex:2];
    [invMan invoke];
    
    BOOL exists;
    [invMan getReturnValue:&exists];
    
    if (!exists) {
        [[ADTAdtraceFactory logger] debug:@"%@ directory not present and will be created", folderName];
        BOOL withIntermediateDirectories = NO;
        NSDictionary *attributes = nil;
        __autoreleasing NSError *error;
        __autoreleasing NSError **errorPointer = &error;
        NSString *keyCrt = [NSString stringWithFormat:@"%@%@%@%@",
                            [NSString adtJoin:@"create", @"directory", @"at", @"path", @":", nil],
                            [NSString adtJoin:@"with", @"intermediate", @"directories", @":", nil],
                            [NSString adtJoin:@"attributes", @":", nil],
                            [NSString adtJoin:@"error", @":", nil]];
        SEL selCrt = NSSelectorFromString(keyCrt);
        if (![man respondsToSelector:selCrt]) {
            return NO;
        }

        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selCrt]];
        [inv setSelector:selCrt];
        [inv setTarget:man];
        [inv setArgument:&path atIndex:2];
        [inv setArgument:&withIntermediateDirectories atIndex:3];
        [inv setArgument:&attributes atIndex:4];
        [inv setArgument:&errorPointer atIndex:5];
        [inv invoke];

        if (error != nil) {
            [[ADTAdtraceFactory logger] error:@"Error while creating %@ directory", path];
            [[ADTAdtraceFactory logger] error:[error description]];
            return NO;
        }
    }
    return YES;
}

+ (NSString *)queryString:(NSDictionary *)parameters {
    return [ADTUtil queryString:parameters queueSize:0];
}

+ (NSString *)queryString:(NSDictionary *)parameters
                queueSize:(NSUInteger)queueSize {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in parameters) {
        NSString *value = [parameters objectForKey:key];
        NSString *escapedValue = [value adtUrlEncode];
        NSString *escapedKey = [key adtUrlEncode];
        NSString *pair = [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue];
        [pairs addObject:pair];
    }

    double now = [NSDate.date timeIntervalSince1970];
    NSString *dateString = [ADTUtil formatSeconds1970:now];
    NSString *escapedDate = [dateString adtUrlEncode];
    NSString *sentAtPair = [NSString stringWithFormat:@"%@=%@", @"sent_at", escapedDate];
    [pairs addObject:sentAtPair];

    if (queueSize > 0) {
        unsigned long queueSizeNative = (unsigned long)queueSize;
        NSString *queueSizeString = [NSString stringWithFormat:@"%lu", queueSizeNative];
        NSString *escapedQueueSize = [queueSizeString adtUrlEncode];
        NSString *queueSizePair = [NSString stringWithFormat:@"%@=%@", @"queue_size", escapedQueueSize];
        [pairs addObject:queueSizePair];
    }

    NSString *queryString = [pairs componentsJoinedByString:@"&"];
    return queryString;
}

+ (BOOL)isNull:(id)value {
    return value == nil || value == (id)[NSNull null];
}

+ (BOOL)isNotNull:(id)value {
    return value != nil && value != (id)[NSNull null];
}

// Convert all values to strings, if value is dictionary -> recursive call
+ (NSDictionary *)convertDictionaryValues:(NSDictionary *)dictionary {
    NSMutableDictionary *convertedDictionary = [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];
    for (NSString *key in dictionary) {
        id value = [dictionary objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            // Dictionary value, recursive call
            NSDictionary *dictionaryValue = [ADTUtil convertDictionaryValues:(NSDictionary *)value];
            [convertedDictionary setObject:dictionaryValue forKey:key];
        } else if ([value isKindOfClass:[NSDate class]]) {
            // Format date to our custom format
            NSString *dateStingValue = [ADTUtil formatDate:value];
            if (dateStingValue != nil) {
                [convertedDictionary setObject:dateStingValue forKey:key];
            }
        } else {
            // Convert all other objects directly to string
            NSString *stringValue = [NSString stringWithFormat:@"%@", value];
            [convertedDictionary setObject:stringValue forKey:key];
        }
    }
    return convertedDictionary;
}

+ (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    id<ADTLogger> logger = ADTAdtraceFactory.logger;

    if ([ADTUtil isNull:url]) {
        [logger error:@"Received universal link is nil"];
        return nil;
    }
    if ([ADTUtil isNull:scheme] || [scheme length] == 0) {
        [logger warn:@"Non-empty scheme required, using the scheme \"AdtraceUniversalScheme\""];
        scheme = kDefaultScheme;
    }
    NSString *urlString = [url absoluteString];
    if ([ADTUtil isNull:urlString]) {
        [logger error:@"Parsed universal link is nil"];
        return nil;
    }
    if (universalLinkRegex == nil) {
        [logger error:@"Universal link regex not correctly configured"];
        return nil;
    }
    if (shortUniversalLinkRegex == nil) {
        [logger error:@"Short Universal link regex not correctly configured"];
        return nil;
    }

    NSArray<NSTextCheckingResult *> *matches = [universalLinkRegex matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    if ([matches count] == 0) {
        matches = [shortUniversalLinkRegex matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
        if ([matches count] == 0) {
            [logger error:@"Url doesn't match as universal link or short version"];
            return nil;
        }
    }
    if ([matches count] > 1) {
        [logger error:@"Url match as universal link multiple times"];
        return nil;
    }

    NSTextCheckingResult *match = matches[0];
    if ([match numberOfRanges] != 2) {
        [logger error:@"Wrong number of ranges matched"];
        return nil;
    }

    NSString *tailSubString = [urlString substringWithRange:[match rangeAtIndex:1]];
    NSString *finalTailSubString = [ADTUtil removeOptionalRedirect:tailSubString];
    NSString *extractedUrlString = [NSString stringWithFormat:@"%@://%@", scheme, finalTailSubString];
    [logger info:@"Converted deeplink from universal link %@", extractedUrlString];
    NSURL *extractedUrl = [NSURL URLWithString:extractedUrlString];
    if ([ADTUtil isNull:extractedUrl]) {
        [logger error:@"Unable to parse converted deeplink from universal link %@", extractedUrlString];
        return nil;
    }
    return extractedUrl;
}

+ (NSString *)removeOptionalRedirect:(NSString *)tailSubString {
    id<ADTLogger> logger = ADTAdtraceFactory.logger;

    if (optionalRedirectRegex == nil) {
        [ADTAdtraceFactory.logger error:@"Remove Optional Redirect regex not correctly configured"];
        return tailSubString;
    }
    NSArray<NSTextCheckingResult *> *optionalRedirectmatches = [optionalRedirectRegex matchesInString:tailSubString
                                                                                              options:0
                                                                                                range:NSMakeRange(0, [tailSubString length])];
    if ([optionalRedirectmatches count] == 0) {
        [logger debug:@"Universal link does not contain option adtrace_redirect parameter"];
        return tailSubString;
    }
    if ([optionalRedirectmatches count] > 1) {
        [logger error:@"Universal link contains multiple option adtrace_redirect parameters"];
        return tailSubString;
    }

    NSTextCheckingResult *redirectMatch = optionalRedirectmatches[0];
    NSRange redirectRange = [redirectMatch rangeAtIndex:0];
    NSString *beforeRedirect = [tailSubString substringToIndex:redirectRange.location];
    NSString *afterRedirect = [tailSubString substringFromIndex:(redirectRange.location + redirectRange.length)];
    if (beforeRedirect.length > 0 && afterRedirect.length > 0) {
        NSString *lastCharacterBeforeRedirect = [beforeRedirect substringFromIndex:beforeRedirect.length - 1];
        NSString *firstCharacterAfterRedirect = [afterRedirect substringToIndex:1];
        if ([@"&" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"&" isEqualToString:firstCharacterAfterRedirect]) {
            beforeRedirect = [beforeRedirect substringToIndex:beforeRedirect.length - 1];
        }
        if ([@"&" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"#" isEqualToString:firstCharacterAfterRedirect]) {
            beforeRedirect = [beforeRedirect substringToIndex:beforeRedirect.length - 1];
        }
        if ([@"?" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"#" isEqualToString:firstCharacterAfterRedirect]) {
            beforeRedirect = [beforeRedirect substringToIndex:beforeRedirect.length - 1];
        }
        if ([@"?" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"&" isEqualToString:firstCharacterAfterRedirect]) {
            afterRedirect = [afterRedirect substringFromIndex:1];
        }
    }
    
    NSString *removedRedirect = [NSString stringWithFormat:@"%@%@", beforeRedirect, afterRedirect];
    return removedRedirect;
}

+ (NSString *)secondsNumberFormat:(double)seconds {
    // Normalize negative zero
    if (seconds < 0) {
        seconds = seconds * -1;
    }
    if (secondsNumberFormatter == nil) {
        return nil;
    }
    return [secondsNumberFormatter stringFromNumber:[NSNumber numberWithDouble:seconds]];
}

+ (double)randomInRange:(double)minRange maxRange:(double)maxRange {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand48(arc4random());
    });
    double random = drand48();
    double range = maxRange - minRange;
    double scaled = random  * range;
    double shifted = scaled + minRange;
    return shifted;
}

+ (NSTimeInterval)waitingTime:(NSInteger)retries
              backoffStrategy:(ADTBackoffStrategy *)backoffStrategy {
    if (retries < backoffStrategy.minRetries) {
        return 0;
    }

    // Start with base 0
    NSInteger base = retries - backoffStrategy.minRetries;
    // Get the exponential Time from the base: 1, 2, 4, 8, 16, ... * times the multiplier
    NSTimeInterval exponentialTime = pow(2.0, base) * backoffStrategy.secondMultiplier;
    // Limit the maximum allowed time to wait
    NSTimeInterval ceilingTime = MIN(exponentialTime, backoffStrategy.maxWait);
    // Add 1 to allow maximum value
    double randomRange = [ADTUtil randomInRange:backoffStrategy.minRange maxRange:backoffStrategy.maxRange];
    // Apply jitter factor
    NSTimeInterval waitingTime =  ceilingTime * randomRange;
    return waitingTime;
}

+ (void)launchInMainThread:(NSObject *)receiver
                  selector:(SEL)selector
                withObject:(id)object {
    if (ADTAdtraceFactory.testing) {
        [ADTAdtraceFactory.logger debug:@"Launching in the background for testing"];
        [receiver performSelectorInBackground:selector withObject:object];
    } else {
        [receiver performSelectorOnMainThread:selector
                                   withObject:object
                                waitUntilDone:NO];  // non-blocking
    }
}

+ (void)launchInMainThread:(dispatch_block_t)block {
    if (ADTAdtraceFactory.testing) {
        [ADTAdtraceFactory.logger debug:@"Launching in the background for testing"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (BOOL)isMainThread {
    return [[NSThread currentThread] isMainThread];
}

+ (BOOL)isInactive {
#if ADTRACE_IM
    // Assume iMessage extension app can't be started from background.
    return NO;
#else
    return [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive;
#endif
}

+ (void)launchInMainThreadWithInactive:(isInactiveInjected)isInactiveblock {
    dispatch_block_t block = ^void(void) {
        __block BOOL isInactive = [ADTUtil isInactive];
        isInactiveblock(isInactive);
    };
    if ([ADTUtil isMainThread]) {
        block();
        return;
    }
    if (ADTAdtraceFactory.testing) {
        [ADTAdtraceFactory.logger debug:@"Launching in the background for testing"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (BOOL)isValidParameter:(NSString *)attribute
           attributeType:(NSString *)attributeType
           parameterName:(NSString *)parameterName {
    if ([ADTUtil isNull:attribute]) {
        [ADTAdtraceFactory.logger error:@"%@ parameter %@ is missing", parameterName, attributeType];
        return NO;
    }
    if ([attribute isEqualToString:@""]) {
        [ADTAdtraceFactory.logger error:@"%@ parameter %@ is empty", parameterName, attributeType];
        return NO;
    }
    return YES;
}

+ (NSDictionary *)mergeParameters:(NSDictionary *)target
                           source:(NSDictionary *)source
                    parameterName:(NSString *)parameterName {
    if (target == nil) {
        return source;
    }
    if (source == nil) {
        return target;
    }

    NSMutableDictionary *mergedParameters = [NSMutableDictionary dictionaryWithDictionary:target];
    [source enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *oldValue = [mergedParameters objectForKey:key];
        if (oldValue != nil) {
            [ADTAdtraceFactory.logger warn:@"Key %@ with value %@ from %@ parameter was replaced by value %@",
             key, oldValue, parameterName, obj];
        }
        [mergedParameters setObject:obj forKey:key];
    }];
    return (NSDictionary *)mergedParameters;
}

+ (void)launchInQueue:(dispatch_queue_t)queue
           selfInject:(id)selfInject
                block:(selfInjectedBlock)block {
    if (queue == nil) {
        return;
    }
    __weak __typeof__(selfInject) weakSelf = selfInject;
    dispatch_async(queue, ^{
        __typeof__(selfInject) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        block(strongSelf);
    });
}

+ (void)launchSynchronisedWithObject:(id)synchronisationObject
                               block:(synchronisedBlock)block {
    @synchronized (synchronisationObject) {
        block();
    }
}

+ (BOOL)deleteFileWithName:(NSString *)fileName {
    NSString *documentsFilePath = [ADTUtil getFilePathInDocumentsDir:fileName];
    NSString *appSupportFilePath = [ADTUtil getFilePathInAppSupportDir:fileName];
    BOOL deletedDocumentsFilePath = [ADTUtil deleteFileInPath:documentsFilePath];
    BOOL deletedAppSupportFilePath = [ADTUtil deleteFileInPath:appSupportFilePath];
    return deletedDocumentsFilePath || deletedAppSupportFilePath;
}

+ (BOOL)deleteFileInPath:(NSString *)filePath {
    Class class = NSClassFromString([NSString adtJoin:@"N", @"S", @"file", @"manager", nil]);
    if (class == nil) {
        return NO;
    }
    NSString *keyDm = [NSString adtJoin:@"default", @"manager", nil];
    SEL selDm = NSSelectorFromString(keyDm);
    if (![class respondsToSelector:selDm]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id man = [class performSelector:selDm];
#pragma clang diagnostic pop
    NSString *keyExi = [NSString adtJoin:@"file", @"exists", @"at", @"path", @":", nil];
    SEL selExi = NSSelectorFromString(keyExi);
    if (![man respondsToSelector:selExi]) {
        return NO;
    }

    NSMethodSignature *msExi = [man methodSignatureForSelector:selExi];
    NSInvocation *invExi = [NSInvocation invocationWithMethodSignature:msExi];
    [invExi setSelector:selExi];
    [invExi setTarget:man];
    [invExi setArgument:&filePath atIndex:2];
    [invExi invoke];
    BOOL exists;
    [invExi getReturnValue:&exists];
    if (!exists) {
        return YES;
    }

    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    NSString *keyRm = [NSString stringWithFormat:@"%@%@",
                        [NSString adtJoin:@"remove", @"item", @"at", @"path", @":", nil],
                        [NSString adtJoin:@"error", @":", nil]];
    SEL selRm = NSSelectorFromString(keyRm);
    if (![man respondsToSelector:selRm]) {
        return NO;
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selRm]];
    [inv setSelector:selRm];
    [inv setTarget:man];
    [inv setArgument:&filePath atIndex:2];
    [inv setArgument:&errorPointer atIndex:3];
    [inv invoke];
    BOOL deleted;
    [inv getReturnValue:&deleted];

    if (!deleted) {
        [[ADTAdtraceFactory logger] verbose:@"Unable to delete file at path %@", filePath];
    }
    if (error) {
        [[ADTAdtraceFactory logger] error:@"Error while deleting file at path %@", filePath];
    }
    return deleted;
}

+ (void)launchDeepLinkMain:(NSURL *)deepLinkUrl {
#if ADTRACE_IM
    // No deep linking in iMessage extension apps.
    return;
#else
    UIApplication *sharedUIApplication = [UIApplication sharedApplication];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL openUrlSelector = @selector(openURL:options:completionHandler:);
#pragma clang diagnostic pop
    if ([sharedUIApplication respondsToSelector:openUrlSelector]) {
        /*
         [sharedUIApplication openURL:deepLinkUrl options:@{} completionHandler:^(BOOL success) {
         if (!success) {
         [ADTAdtraceFactory.logger error:@"Unable to open deep link (%@)", deepLinkUrl];
         }
         }];
         */
        NSMethodSignature *methSig = [sharedUIApplication methodSignatureForSelector:openUrlSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methSig];
        [invocation setSelector: openUrlSelector];
        [invocation setTarget: sharedUIApplication];
        NSDictionary *emptyDictionary = @{};
        void (^completion)(BOOL) = ^(BOOL success) {
            if (!success) {
                [ADTAdtraceFactory.logger error:@"Unable to open deep link (%@)", deepLinkUrl];
            }
        };
        [invocation setArgument:&deepLinkUrl atIndex: 2];
        [invocation setArgument:&emptyDictionary atIndex: 3];
        [invocation setArgument:&completion atIndex: 4];
        [invocation invoke];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BOOL success = [sharedUIApplication openURL:deepLinkUrl];
#pragma clang diagnostic pop
        if (!success) {
            [ADTAdtraceFactory.logger error:@"Unable to open deep link without completionHandler (%@)", deepLinkUrl];
        }
    }
#endif
}

// adapted from https://stackoverflow.com/a/9084784
+ (NSString *)convertDeviceToken:(NSData *)deviceToken {
    NSUInteger dataLength  = [deviceToken length];

    if (dataLength == 0) {
        return nil;
    }

    const unsigned char *dataBuffer = (const unsigned char *)[deviceToken bytes];

    if (!dataBuffer) {
        return nil;
    }

    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (NSUInteger i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }

    return [hexString copy];
}

+ (BOOL)checkAttributionDetails:(NSDictionary *)attributionDetails {
    if ([ADTUtil isNull:attributionDetails]) {
        return NO;
    }

    NSDictionary *details = [attributionDetails objectForKey:@"Version3.1"];
    if ([ADTUtil isNull:details]) {
        return YES;
    }

    // Common fields for both iAd3 and Apple Search Ads
    if (![ADTUtil contains:details key:@"iad-org-name" value:@"OrgName"] ||
        ![ADTUtil contains:details key:@"iad-campaign-id" value:@"1234567890"] ||
        ![ADTUtil contains:details key:@"iad-campaign-name" value:@"CampaignName"] ||
        ![ADTUtil contains:details key:@"iad-lineitem-id" value:@"1234567890"] ||
        ![ADTUtil contains:details key:@"iad-lineitem-name" value:@"LineName"]) {
        [ADTAdtraceFactory.logger debug:@"iAd attribution details has dummy common fields for both iAd3 and Apple Search Ads"];
        return YES;
    }
    // Apple Search Ads fields
    if ([ADTUtil contains:details key:@"iad-adgroup-id" value:@"1234567890"] &&
        [ADTUtil contains:details key:@"iad-keyword" value:@"Keyword"] && (
            [ADTUtil contains:details key:@"iad-adgroup-name" value:@"AdgroupName"] ||
            [ADTUtil contains:details key:@"iad-adgroup-name" value:@"AdGroupName"]
        )) {
        [ADTAdtraceFactory.logger debug:@"iAd attribution details has dummy Apple Search Ads fields"];
        return NO;
    }
    // iAd3 fields
    if ([ADTUtil contains:details key:@"iad-adgroup-id" value:@"1234567890"] &&
        [ADTUtil contains:details key:@"iad-creative-name" value:@"CreativeName"]) {
        [ADTAdtraceFactory.logger debug:@"iAd attribution details has dummy iAd3 fields"];
        return NO;
    }

    return YES;
}

+ (BOOL)contains:(NSDictionary *)dictionary
        key:(NSString *)key
        value:(NSString *)value {
    id readValue = [dictionary objectForKey:key];
    if ([ADTUtil isNull:readValue]) {
        return NO;
    }
    return [value isEqualToString:[readValue description]];
}

+ (BOOL)isDeeplinkValid:(NSURL *)url {
    if (url == nil) {
        return NO;
    }
    if ([[url absoluteString] length] == 0) {
        return NO;
    }
    if (excludedDeeplinkRegex == nil) {
        [ADTAdtraceFactory.logger error:@"Excluded deep link regex not correctly configured"];
        return NO;
    }

    NSString *urlString = [url absoluteString];
    NSArray<NSTextCheckingResult *> *matches = [excludedDeeplinkRegex matchesInString:urlString
                                                                              options:0
                                                                                range:NSMakeRange(0, [urlString length])];
    if ([matches count] > 0) {
        [ADTAdtraceFactory.logger debug:@"Deep link (%@) processing skipped", urlString];
        return NO;
    }

    return YES;
}

+ (NSString *)sdkVersion {
    return kClientSdk;
}

+ (void)updateSkAdNetworkConversionValue:(NSNumber *)conversionValue {
    id<ADTLogger> logger = [ADTAdtraceFactory logger];
    
    Class skAdNetwork = NSClassFromString(@"SKAdNetwork");
    if (skAdNetwork == nil) {
        [logger warn:@"StoreKit framework not found in the app (SKAdNetwork not found)"];
        return;
    }
    
    SEL updateConversionValueSelector = NSSelectorFromString(@"updateConversionValue:");
    if ([skAdNetwork respondsToSelector:updateConversionValueSelector]) {
        NSInteger intValue = [conversionValue integerValue];
        
        NSMethodSignature *conversionValueMethodSignature = [skAdNetwork methodSignatureForSelector:updateConversionValueSelector];
        NSInvocation *conversionInvocation = [NSInvocation invocationWithMethodSignature:conversionValueMethodSignature];
        [conversionInvocation setSelector:updateConversionValueSelector];
        [conversionInvocation setTarget:skAdNetwork];

        [conversionInvocation setArgument:&intValue atIndex:2];
        [conversionInvocation invoke];
        
        [logger verbose:@"Call to SKAdNetwork's updateConversionValue: method made with value %d", intValue];
    }
}

+ (Class)adSupportManager {
    NSString *className = [NSString adtJoin:@"A", @"S", @"identifier", @"manager", nil];
    Class class = NSClassFromString(className);
    return class;
}

+ (Class)appTrackingManager {
    NSString *className = [NSString adtJoin:@"A", @"T", @"tracking", @"manager", nil];
    Class class = NSClassFromString(className);
    return class;
}

+ (BOOL)trackingEnabled {
#if ADTRACE_NO_IDFA
    return NO;
#else
    // return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    Class adSupportClass = [ADTUtil adSupportManager];
    if (adSupportClass == nil) {
        return NO;
    }

    NSString *keyManager = [NSString adtJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id manager = [adSupportClass performSelector:selManager];
    NSString *keyEnabled = [NSString adtJoin:@"is", @"advertising", @"tracking", @"enabled", nil];
    SEL selEnabled = NSSelectorFromString(keyEnabled);
    if (![manager respondsToSelector:selEnabled]) {
        return NO;
    }
    
    NSMethodSignature *msEnabled = [manager methodSignatureForSelector:selEnabled];
    NSInvocation *invEnabled = [NSInvocation invocationWithMethodSignature:msEnabled];
    [invEnabled setSelector:selEnabled];
    [invEnabled setTarget:manager];
    [invEnabled invoke];
    BOOL enabled;
    [invEnabled getReturnValue:&enabled];
    return enabled;
#pragma clang diagnostic pop
#endif
}

+ (NSString *)idfa {
#if ADTRACE_NO_IDFA
    return @"";
#else
    // return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    Class adSupportClass = [ADTUtil adSupportManager];
    if (adSupportClass == nil) {
        return @"";
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *keyManager = [NSString adtJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return @"";
    }
    id manager = [adSupportClass performSelector:selManager];
    NSString *keyIdentifier = [NSString adtJoin:@"advertising", @"identifier", nil];
    SEL selIdentifier = NSSelectorFromString(keyIdentifier);
    if (![manager respondsToSelector:selIdentifier]) {
        return @"";
    }
    id identifier = [manager performSelector:selIdentifier];
    NSString *keyString = [NSString adtJoin:@"UUID", @"string", nil];
    SEL selString = NSSelectorFromString(keyString);
    if (![identifier respondsToSelector:selString]) {
        return @"";
    }
    NSString *string = [identifier performSelector:selString];
    return string;
#pragma clang diagnostic pop
#endif
}

+ (NSString *)idfv {
    Class class = NSClassFromString([NSString adtJoin:@"U", @"I", @"device", nil]);
    if (class == nil) {
        return nil;
    }
    NSString *keyCd = [NSString adtJoin:@"current", @"device", nil];
    SEL selCd = NSSelectorFromString(keyCd);
    if (![class respondsToSelector:selCd]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id dev = [class performSelector:selCd];
#pragma clang diagnostic pop
    NSString *keyIfv = [NSString adtJoin:@"identifier", @"for", @"vendor", nil];
    SEL selIfv = NSSelectorFromString(keyIfv);
    if (![dev respondsToSelector:selIfv]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSUUID *uuid = (NSUUID *)[dev performSelector:selIfv];
#pragma clang diagnostic pop
    if (uuid == nil) {
        return nil;
    }
    return [uuid UUIDString];
}

+ (NSString *)fbAnonymousId {
#if TARGET_OS_TV
    return @"";
#else
    // pre FB SDK v6.0.0
    // return [FBSDKAppEventsUtility retrievePersistedAnonymousID];
    // post FB SDK v6.0.0
    // return [FBSDKBasicUtility retrievePersistedAnonymousID];
    Class class = nil;
    SEL selGetId = NSSelectorFromString(@"retrievePersistedAnonymousID");
    class = NSClassFromString(@"FBSDKBasicUtility");
    if (class != nil) {
        if ([class respondsToSelector:selGetId]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *fbAnonymousId = (NSString *)[class performSelector:selGetId];
            return fbAnonymousId;
#pragma clang diagnostic pop
        }
    }
    class = NSClassFromString(@"FBSDKAppEventsUtility");
    if (class != nil) {
        if ([class respondsToSelector:selGetId]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *fbAnonymousId = (NSString *)[class performSelector:selGetId];
            return fbAnonymousId;
#pragma clang diagnostic pop
        }
    }
    return @"";
#endif
}

+ (NSString *)deviceType {
    Class class = NSClassFromString([NSString adtJoin:@"U", @"I", @"device", nil]);
    if (class == nil) {
        return nil;
    }
    NSString *keyCd = [NSString adtJoin:@"current", @"device", nil];
    SEL selCd = NSSelectorFromString(keyCd);
    if (![class respondsToSelector:selCd]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id dev = [class performSelector:selCd];
#pragma clang diagnostic pop
    NSString *keyM = [NSString adtJoin:@"model", nil];
    SEL selM = NSSelectorFromString(keyM);
    if (![dev respondsToSelector:selM]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return (NSString *)[dev performSelector:selM];
#pragma clang diagnostic pop
}

+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return @(systemInfo.machine);
}

+ (NSUInteger)startedAt {
    int MIB_SIZE = 2;
    int mib[MIB_SIZE];
    size_t size;
    struct timeval starttime;
    mib[0] = CTL_KERN;
    mib[1] = KERN_BOOTTIME;
    size = sizeof(starttime);

    NSString *m = [[NSString adtJoin:@"s", @"ys", @"ct", @"l", nil] lowercaseString];
    int (*fptr)(int *, u_int, void *, size_t *, void *, size_t);
    *(int**)(&fptr) = dlsym(RTLD_SELF, [m UTF8String]);
    if (fptr) {
        if ((*fptr)(mib, MIB_SIZE, &starttime, &size, NULL, 0) != -1) {
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:starttime.tv_sec];
            return (NSUInteger)round([startDate timeIntervalSince1970]);
        }
    }

    return 0;
}

+ (int)attStatus {
    Class appTrackingClass = [self appTrackingManager];
    if (appTrackingClass != nil) {
        NSString *keyAuthorization = [NSString adtJoin:@"tracking", @"authorization", @"status", nil];
        SEL selAuthorization = NSSelectorFromString(keyAuthorization);
        if ([appTrackingClass respondsToSelector:selAuthorization]) {
            NSMethodSignature *msAuthorization = [appTrackingClass methodSignatureForSelector:selAuthorization];
            NSInvocation *invAuthorization = [NSInvocation invocationWithMethodSignature:msAuthorization];
            [invAuthorization setSelector:selAuthorization];
            [invAuthorization invokeWithTarget:appTrackingClass];
            [invAuthorization invoke];
            NSUInteger status;
            [invAuthorization getReturnValue:&status];
            return (int)status;
        }
    }
    return -1;
}

+ (NSString *)fetchAdServicesAttribution:(NSError **)errorPtr {
    id<ADTLogger> logger = [ADTAdtraceFactory logger];

    // [AAAttribution attributionTokenWithError:...]
    Class attributionClass = NSClassFromString(@"AAAttribution");
    if (attributionClass == nil) {
        [logger warn:@"AdServices framework not found in the app (AAAttribution class not found)"];
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:@"io.adtrace.sdk.adServices"
                                            code:100
                                        userInfo:@{@"Error reason": @"AdServices framework not found"}];
        }
        return nil;
    }

    SEL attributionTokenSelector = NSSelectorFromString(@"attributionTokenWithError:");
    if (![attributionClass respondsToSelector:attributionTokenSelector]) {
        [logger warn:@"AdServices framework not found in the app (attributionTokenWithError: method not found)"];
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:@"io.adtrace.sdk.adServices"
                                            code:100
                                        userInfo:@{@"Error reason": @"AdServices framework not found"}];
        }
        return nil;
    }
    
    NSMethodSignature *attributionTokenMethodSignature = [attributionClass methodSignatureForSelector:attributionTokenSelector];
    NSInvocation *tokenInvocation = [NSInvocation invocationWithMethodSignature:attributionTokenMethodSignature];
    [tokenInvocation setSelector:attributionTokenSelector];
    [tokenInvocation setTarget:attributionClass];
    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    [tokenInvocation setArgument:&errorPointer atIndex:2];
    [tokenInvocation invoke];

    if (error) {
        [logger error:@"Error while retrieving AdServices attribution token: %@", error];
        if (errorPtr) {
            *errorPtr = error;
        }
        return nil;
    }

    [logger debug:@"AdServices framework successfully found in the app"];
    NSString * __unsafe_unretained tmpToken = nil;
    [tokenInvocation getReturnValue:&tmpToken];
    NSString *token = tmpToken;
    return token;
}

+ (void)checkForiAd:(ADTActivityHandler *)activityHandler queue:(dispatch_queue_t)queue {
    // if no tries for iAd v3 left, stop trying
    id<ADTLogger> logger = [ADTAdtraceFactory logger];

#if ADTRACE_NO_IAD || TARGET_OS_TV
    [logger debug:@"ADTRACE_NO_IAD or TARGET_OS_TV set"];
    return;
#else
    [logger debug:@"ADTRACE_NO_IAD or TARGET_OS_TV not set"];

    // [[ADClient sharedClient] ...]
    Class ADClientClass = NSClassFromString(@"ADClient");
    if (ADClientClass == nil) {
        [logger warn:@"iAd framework not found in the app (ADClientClass not found)"];
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sharedClientSelector = NSSelectorFromString(@"sharedClient");
    if (![ADClientClass respondsToSelector:sharedClientSelector]) {
        [logger warn:@"iAd framework not found in the app (sharedClient method not found)"];
        return;
    }
    id ADClientSharedClientInstance = [ADClientClass performSelector:sharedClientSelector];
    if (ADClientSharedClientInstance == nil) {
        [logger warn:@"iAd framework not found in the app (ADClientSharedClientInstance is nil)"];
        return;
    }
    [logger debug:@"iAd framework successfully found in the app"];
    BOOL iAdInformationAvailable = [ADTUtil setiAdWithDetails:activityHandler
                                       adClientSharedInstance:ADClientSharedClientInstance
                                                        queue:queue];
    if (!iAdInformationAvailable) {
        [logger warn:@"iAd information not available"];
        return;
    }
#pragma clang diagnostic pop
#endif
}

+ (BOOL)setiAdWithDetails:(ADTActivityHandler *)activityHandler
   adClientSharedInstance:(id)ADClientSharedClientInstance
                    queue:(dispatch_queue_t)queue {
    SEL iAdDetailsSelector = NSSelectorFromString(@"requestAttributionDetailsWithBlock:");
    if (![ADClientSharedClientInstance respondsToSelector:iAdDetailsSelector]) {
        return NO;
    }

    __block Class lock = [ADTActivityHandler class];
    __block BOOL completed = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [ADClientSharedClientInstance performSelector:iAdDetailsSelector
                                       withObject:^(NSDictionary *attributionDetails, NSError *error) {
        @synchronized (lock) {
            if (completed) {
                return;
            } else {
                completed = YES;
            }
        }
        [activityHandler setAttributionDetails:attributionDetails
                                         error:error];
    }];
#pragma clang diagnostic pop

    // 5 seconds of timeout
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), queue, ^{
        @synchronized (lock) {
            if (completed) {
                return;
            } else {
                completed = YES;
            }
        }
        [activityHandler setAttributionDetails:nil
                                         error:[NSError errorWithDomain:@"io.adtrace.sdk.iAd"
                                                                   code:100
                                                               userInfo:@{@"Error reason": @"iAd request timed out"}]];
    });
    return YES;
}

+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(NSUInteger status))completion {
    Class appTrackingClass = [self appTrackingManager];
    if (appTrackingClass == nil) {
        return;
    }
    NSString *requestAuthorization = [NSString adtJoin:
                                      @"request",
                                      @"tracking",
                                      @"authorization",
                                      @"with",
                                      @"completion",
                                      @"handler:", nil];
    SEL selRequestAuthorization = NSSelectorFromString(requestAuthorization);
    if (![appTrackingClass respondsToSelector:selRequestAuthorization]) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [appTrackingClass performSelector:selRequestAuthorization withObject:completion];
#pragma clang diagnostic pop
}

+ (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)buildNumber {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleVersion"];
}

+ (NSString *)versionNumber {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)osVersion {
    Class class = NSClassFromString([NSString adtJoin:@"U", @"I", @"device", nil]);
    if (class == nil) {
        return nil;
    }
    NSString *keyCd = [NSString adtJoin:@"current", @"device", nil];
    SEL selCd = NSSelectorFromString(keyCd);
    if (![class respondsToSelector:selCd]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id dev = [class performSelector:selCd];
#pragma clang diagnostic pop
    NSString *keySv = [NSString adtJoin:@"system", @"version", nil];
    SEL selSv = NSSelectorFromString(keySv);
    if (![dev respondsToSelector:selSv]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return (NSString *)[dev performSelector:selSv];
#pragma clang diagnostic pop
}

+ (NSString *)installedAt {
    id<ADTLogger> logger = ADTAdtraceFactory.logger;
    NSDate *installTime = nil;
    NSString *pathToCheck = nil;
    NSSearchPathDirectory folderToCheck = NSDocumentDirectory;
#if TARGET_OS_TV
    folderToCheck = NSCachesDirectory;
#endif
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(folderToCheck, NSUserDomainMask, YES);
        if (paths.count > 0) {
            pathToCheck = [paths objectAtIndex:0];
        } else {
            pathToCheck = [[NSBundle mainBundle] bundlePath];
        }

        __autoreleasing NSError *error;
        __autoreleasing NSError **errorPointer = &error;
        Class class = NSClassFromString([NSString adtJoin:@"N", @"S", @"file", @"manager", nil]);
        if (class != nil) {
            NSString *keyDm = [NSString adtJoin:@"default", @"manager", nil];
            SEL selDm = NSSelectorFromString(keyDm);
            if ([class respondsToSelector:selDm]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id man = [class performSelector:selDm];
#pragma clang diagnostic pop
                NSString *keyChk = [NSString stringWithFormat:@"%@%@",
                        [NSString adtJoin:@"attributes", @"of", @"item", @"at", @"path", @":", nil],
                        [NSString adtJoin:@"error", @":", nil]];
                SEL selChk = NSSelectorFromString(keyChk);
                if ([man respondsToSelector:selChk]) {
                    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selChk]];
                    [inv setSelector:selChk];
                    [inv setTarget:man];
                    [inv setArgument:&pathToCheck atIndex:2];
                    [inv setArgument:&errorPointer atIndex:3];
                    [inv invoke];
                    NSMutableDictionary * __unsafe_unretained tmpResult;
                    [inv getReturnValue:&tmpResult];
                    NSMutableDictionary *result = tmpResult;
                    CFStringRef *indexRef = dlsym(RTLD_SELF, [[NSString adtJoin:@"N", @"S", @"file", @"creation", @"date", nil] UTF8String]);
                    NSString *ref = (__bridge_transfer id) *indexRef;
                    installTime = result[ref];
                }
            }
        }
    } @catch (NSException *exception) {
        [logger error:@"Error while trying to check install date. Exception: %@", exception];
        return nil;
    }

    return [ADTUtil formatDate:installTime];
}

+ (NSString *)generateRandomUuid {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString *uuidString = (__bridge_transfer NSString*)stringRef;
    NSString *lowerUuid = [uuidString lowercaseString];
    CFRelease(newUniqueId);
    return lowerUuid;
}

+ (NSString *)getPersistedRandomToken {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = @"adtrace_uuid";
    keychainItem[(__bridge id)kSecAttrService] = @"deviceInfo";
    if (!keychainItem) {
        return nil;
    }

    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    if (status != noErr) {
        return nil;
    }

    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
    NSData *data = resultDict[(__bridge id)kSecValueData];
    if (!data) {
        return nil;
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (BOOL)setPersistedRandomToken:(NSString *)randomToken {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = @"adtrace_uuid";
    keychainItem[(__bridge id)kSecAttrService] = @"deviceInfo";
    keychainItem[(__bridge id)kSecValueData] = [randomToken dataUsingEncoding:NSUTF8StringEncoding];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
    if (status != noErr) {
        [[ADTAdtraceFactory logger] warn:@"Primary dedupe token unsuccessfully written"];
        return NO;
    } else {
        NSString *persistedRandomToken = [ADTUtil getPersistedRandomToken];
        if ([randomToken isEqualToString:persistedRandomToken]) {
            [[ADTAdtraceFactory logger] debug:@"Primary dedupe token successfully written"];
            return YES;
        } else {
            return NO;
        }
    }
}

@end
