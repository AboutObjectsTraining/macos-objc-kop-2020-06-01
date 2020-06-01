// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Foundation/Foundation.h>

@class Dog;

@interface Person : NSObject {
    NSString *_firstName;
    NSString *_lastName;
    NSInteger _age;
    Dog *_dog;
}

- (NSString *)firstName;
- (void)setFirstName:(NSString *)newValue;

- (NSString *)lastName;
- (void)setLastName:(NSString *)newValue;

- (NSString *)fullName;

- (NSInteger)age;
- (void)setAge:(NSInteger)newValue;

- (Dog *)dog;
- (void)setDog:(Dog *)newValue;

@end

