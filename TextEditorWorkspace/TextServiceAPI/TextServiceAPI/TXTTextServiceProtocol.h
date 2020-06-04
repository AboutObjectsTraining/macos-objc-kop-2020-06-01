// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Foundation/Foundation.h>

#define TXTTextServiceName @"com.aboutobjects.training.TextService"

@protocol TXTTextServiceProtocol <NSObject>

- (void)uppercaseString:(NSString *)text completionHandler:(void (^)(NSString *))completionHandler;

- (void)ping;

@end
