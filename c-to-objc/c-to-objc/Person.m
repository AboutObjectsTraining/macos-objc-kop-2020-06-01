// Copyright (C) 2018 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import "Person.h"

NSString * const NotAvailable = @"N/A";

@implementation Person

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                              age:(int)age
{
    self = [super init];
    if (self == nil) return nil;
    
    _firstName = firstName;
    _lastName = lastName;
    _age = age;
    
    return self;
}

- (NSString *)firstName {
    return _firstName;
}

- (void)setFirstName:(NSString *)newValue {
    _firstName = [newValue copy];
}

- (void)print
{
    NSLog(@"%@, %@, Age: %d",
          _lastName == nil ? NotAvailable : _lastName,
          _firstName == nil ? NotAvailable : _firstName,
          _age);
}

@end
