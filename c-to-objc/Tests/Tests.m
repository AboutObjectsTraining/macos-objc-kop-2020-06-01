// Copyright (C) 2018 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <XCTest/XCTest.h>
#import "Person.h"
#import <objc/objc-runtime.h>

@interface Tests : XCTestCase
@end

// To use the runtime C API to send a message, you must initialize a
// function pointer with a cast to an appopriate variant of objc_msgSend.
//
id (* send_msg)(id, SEL, ...) = (id (*)(id, SEL, ...))objc_msgSend;

@implementation Tests

- (void)setUp    { putchar('\n'); }
- (void)tearDown { putchar('\n'); }

- (void)testMessageSendWithString
{
    NSString *word = @"hello";
    
    // Obtaining a selector (string representation) from a method symbol
    SEL capitalizedString = @selector(capitalizedString);
    
    // Sending a message via the runtime C API
    NSString *capitalizedWord = send_msg(word, capitalizedString);
    NSLog(@"%@", capitalizedWord);
}

- (void)testMessageExpressionWithString
{
    NSString *word = @"world";
    
    // Using an Objective-C message expression
    NSString *capitalizedWord = [word capitalizedString];
    NSLog(@"%@", capitalizedWord);
}

- (void)testMessageSend
{
    // Allocating and initializing an instance of Person
    Person *fred = [[Person alloc] initWithFirstName:@"Fred"
                                            lastName:@"Smith"
                                                 age:32];
    
    // Obtaining a selector (string representation) from a method symbol
    SEL print = @selector(print);
    send_msg(fred, print);
    
    send_msg(fred, @selector(setFirstName:), @"Chip");
    send_msg(fred, print);
    
    [fred setFirstName:@"Frederick"];
    [fred print];
    
    // Allocating and initializing an instance
    Person *sue = send_msg(send_msg(Person.class, @selector(alloc)),
                           @selector(initWithFirstName:lastName:age:),
                           @"Sue", @"Yu", 42);
    
    [sue print];
}

@end
