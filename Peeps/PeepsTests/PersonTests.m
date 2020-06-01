// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <XCTest/XCTest.h>
#import <Peeps/Peeps.h>

@interface Person (EvilTestingHack)
- (void)setFirstName:(NSString *)aFirstName lastName:(NSString *)aLastName;
@end

@interface PersonTests : XCTestCase
@end

@implementation PersonTests

- (void)testCreatePerson {
    Person *person = [[Person alloc] init];
    [person setFirstName:@"Fred"];
    [person setLastName:@"Smith"];
    [person setAge:42];
    
    NSLog(@"%@", person);
}

- (void)testPrivateMethod {
    Person *person = [[Person alloc] init];
    [person setFirstName:@"Fred" lastName:@"Smith"];
    NSLog(@"%@", person);
    
    Person *foo = nil;
    [foo setFirstName:@"Foo"];
    NSLog(@"%@", foo);
}

- (void)testMessageForwarding {
    id person = [[Person alloc] init];
    [person setFirstName:@"Fred"];
    [person setLastName:@"Smith"];
    [person setAge:42];
    
    Dog *dog = [[Dog alloc] init];
    [person setDog:dog];
    
    if ([person respondsToSelector:@selector(bark)]) {
        [person bark];
    }
}

@end
