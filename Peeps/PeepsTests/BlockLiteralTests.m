// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <XCTest/XCTest.h>

@interface BlockLiteralTests : XCTestCase
@property (copy, nonatomic) NSString *text;
@end

void sayHello(void) {
    printf("Hello!\n");
}

void saySomethingNTimes(void (*thingToSay)(void)) {
    for (int i = 0; i < 3; i++) {
        thingToSay();
    }
}

void saySomethingBlockish(void (^thingToSay)(void)) {
    for (int i = 0; i < 3; i++) {
        thingToSay();
    }
}

NSString * const CurrentWeather = @"Sunny";

@implementation BlockLiteralTests

- (void)setUp {
    self.text = @"Woohoo!";
}

- (void)testFunctionPointer {
    void (*myPtr)(void) = sayHello;
    myPtr();
    
    saySomethingNTimes(myPtr);
}

- (void)testBlockLiteral {
    void (^myBlock)(void) = ^{
        printf("Hello from my block!\n");
    };
    
    myBlock();
    saySomethingBlockish(myBlock);
    NSLog(@"%@", [myBlock description]);
    
    void (^copyOfMyBlock)(void) = [myBlock copy];
    copyOfMyBlock();
    NSLog(@"%@", copyOfMyBlock);
}

- (void)testBlockLiteralCapturingState {
    int __block count = 0;
    void (^myBlock)(void) = ^{
        count++;
        printf("Hello from my block! %s The weather is %s\n", self.text.UTF8String, CurrentWeather.UTF8String);
    };
    saySomethingBlockish(myBlock);
    NSLog(@"%@", myBlock);
    
    void (^copyOfMyBlock)(void) = [myBlock copy];
    copyOfMyBlock();
    NSLog(@"%@", copyOfMyBlock);
}

@end
