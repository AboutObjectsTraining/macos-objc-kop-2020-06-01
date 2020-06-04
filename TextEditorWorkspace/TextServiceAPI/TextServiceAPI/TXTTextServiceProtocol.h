// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Foundation/Foundation.h>

@protocol TXTTextServiceProtocol <NSObject>

- (void)uppercaseString:(NSString *)text completionHandler:(void (^)(NSString *))completionHandler;

@end
