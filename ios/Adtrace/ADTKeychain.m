//
//  ADTKeychain.m
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTLogger.h"
#import "ADTKeychain.h"
#import "ADTAdtraceFactory.h"
#include <dlfcn.h>

@implementation ADTKeychain

#pragma mark - Object lifecycle methods

+ (id)getInstance {
    static ADTKeychain *defaultInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    return self;
}

#pragma mark - Public methods

+ (BOOL)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    if (key == nil) {
        return NO;
    }

    return [[ADTKeychain getInstance] setValue:value forKeychainKey:key inService:service];
}

+ (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service {
    if (key == nil) {
        return nil;
    }

    return [[ADTKeychain getInstance] valueForKeychainKey:key service:service];
}

#pragma mark - Set Keychain item value

- (BOOL)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    OSStatus status = [self setValueWithStatus:value forKeychainKey:key inService:service];

    if (status != noErr) {
        [[ADTAdtraceFactory logger] warn:@"Value unsuccessfully written to the keychain"];
        return NO;
    } else {
        // Check was writing successful.
        BOOL wasSuccessful = [self wasWritingSuccessful:value forKeychainKey:key inService:service];

        if (wasSuccessful) {
            [[ADTAdtraceFactory logger] warn:@"Value successfully written to the keychain"];
        }

        return wasSuccessful;
    }
}

- (OSStatus)setValueWithStatus:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSMutableDictionary *keychainItem;
    
    keychainItem = [self keychainItemForKey:key service:service];
    keychainItem[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
    
    return SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

#pragma mark - Get Keychain item value

- (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [self keychainItemForKey:key service:service];
    return [self valueForKeychainItem:keychainItem key:key service:service];
}

- (NSString *)valueForKeychainItem:(NSMutableDictionary *)keychainItem key:(NSString *)key service:(NSString *)service {
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

#pragma mark - Build Keychain item

- (NSMutableDictionary *)keychainItemForKey:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];

    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    [self keychainItemForKey:keychainItem key:key service:service];

    return keychainItem;
}

- (void)keychainItemForKey:(NSMutableDictionary *)keychainItem key:(NSString *)key service:(NSString *)service {
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecAttrService] = service;
}

#pragma mark - Writing validation

- (BOOL)wasWritingSuccessful:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSString *writtenValue = [self valueForKeychainKey:key service:service];
    if ([writtenValue isEqualToString:value]) {
        return YES;
    } else {
        return NO;
    }
}

@end
