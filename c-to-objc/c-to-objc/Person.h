// Copyright (C) 2018 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Foundation/Foundation.h>

@interface Person : NSObject
{
    NSString *_firstName;
    NSString *_lastName;
    int _age;
}

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                              age:(int)age;

- (NSString *)firstName;
- (void)setFirstName:(NSString *)newValue;

- (void)print;

@end
