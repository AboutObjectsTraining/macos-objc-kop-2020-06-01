// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import "TXTTextService.h"

@implementation TXTTextService

- (void)uppercaseString:(NSString *)text completionHandler:(void (^)(NSString *))completionHandler {
    completionHandler(text.uppercaseString);
}

- (void)capitalizeString:(NSString *)text completionHandler:(void (^)(NSString *))completionHandler {
    completionHandler(text.capitalizedString);
}

- (void)lowercaseString:(NSString *)text completionHandler:(void (^)(NSString *))completionHandler {
    completionHandler(text.lowercaseString);
}

- (void)ping { }

@end
