// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import "Person.h"
#import "Dog.h"

@implementation Person

- (NSString *)firstName {
    return _firstName;
}
- (void)setFirstName:(NSString *)newValue {
    _firstName = [newValue copy];
}

- (NSString *)lastName {
    return _lastName;
}
- (void)setLastName:(NSString *)newValue {
    _lastName = [newValue copy];
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", [self firstName], [self lastName]];
}

// Don't do this in real life!
- (void)setFirstName:(NSString *)aFirstName
            lastName:(NSString *)aLastName {
    
    [self setFirstName:aFirstName];
    [self setLastName:aLastName];
}

- (NSInteger)age {
    return _age;
}
- (void)setAge:(NSInteger)newValue {
    _age = newValue;
}

- (Dog *)dog {
    return _dog;
}
- (void)setDog:(Dog *)newValue {
    _dog = newValue;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, age: %@", [self fullName], @([self age])];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    if ([[self dog] respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([[self dog] respondsToSelector:aSelector]) {
        return [self dog];
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
