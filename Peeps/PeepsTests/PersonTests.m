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

- (void)testCopyingBehavior {
    Dog *dog = [[Dog alloc] init];
    [dog setName:@"Rover"];
    
    Dog *copyOfDog = [dog copy];
    NSLog(@"Copy of dog's name is %@", [copyOfDog name]);
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

- (void)testDesignatedInitializer {
    Person *person = [[Person alloc] initWithFirstName:@"Fred"
                                              lastName:@"Smith"
                                                   age:42];
    NSLog(@"%@", person);
}

- (void)testInheritedInitializers {
    Employee *emp = [Employee personWithFirstName:@"Fred" lastName:@"Smith" age:33];
    NSLog(@"%@", emp);
}

@end
