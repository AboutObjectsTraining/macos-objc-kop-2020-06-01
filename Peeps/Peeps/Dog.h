// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Foundation/Foundation.h>

@interface Dog : NSObject {
    NSString *_name;
}

- (NSString *)name;
- (void)setName:(NSString *)newValue;

- (void)bark;

@end
