// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <XCTest/XCTest.h>

@interface CollectionTests : XCTestCase
@end

@implementation CollectionTests

- (void)testStringClassCluster {
    NSString *s1 = [NSString alloc];
    NSString *s2 = [NSString alloc];
    NSMutableString *s3 = [NSMutableString alloc];
    NSMutableString *s4 = [NSMutableString alloc];
    
    s1 = [s1 initWithFormat:@"%@ %@", @"Hello", @"World!"];
    s2 = [s2 initWithString:@"Woo!"];
    s3 = [s3 initWithFormat:@"%@ %@", @"Hello", @"World!"];
    s4 = [s4 initWithString:@"Foo!"];
    
    NSLog(@"%@", s1);
    NSLog(@"%@", s2);
}

@end
