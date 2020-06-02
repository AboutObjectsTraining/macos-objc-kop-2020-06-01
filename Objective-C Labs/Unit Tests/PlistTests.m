// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <XCTest/XCTest.h>
#import "Person.h"

@interface DictionaryTests : XCTestCase
@end

@implementation DictionaryTests

- (void)testMutableDictionary {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:@"Fred" forKey:@"firstName"];
    [info setObject:@42 forKey:@"age"];
    NSLog(@"%@", info);

    NSNumber *age = [info objectForKey:@"age"];
    NSLog(@"%d", age.intValue);
}

- (void)testMutableDictionaryUsingSubscripts {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"firstName"] = @"Fred";
    info[@"age"] = @42;
    NSLog(@"%@", info);
    
    NSNumber *age = info[@"age"];
    NSLog(@"%d", age.intValue);
}

- (void)testDictionaryLiteral {
    NSDictionary *info = @{ @"name" : @"Fred",
                            @"age"  : @32 };
    
    for (NSString *key in info) {
        NSLog(@"key: %@, value: %@", key, info[key]);
    }
}

- (void)testCreatePlist {
    NSDictionary *info = @{ @"name" : @"Fred W. Smith", @"age" : @37,
                            @"phones" : @{@"Work" : @"703-123-4567", @"Home" : @"301-987-6543"},
                            @"kids"   : @[@"Bob", @"Alice", @"Jill"] };
    NSLog(@"%@", info);
    
    // Write to plist file.
    [info writeToFile:@"/tmp/info.plist" atomically:YES];
    
    // Initialize new instance with contents of plist.
    NSDictionary *newInfo = [NSDictionary dictionaryWithContentsOfFile:@"/tmp/info.plist"];
    
    NSLog(@"%@", newInfo);
}

- (void)testKVC {
    NSDictionary *info = @{ @"firstName" : @"Fred",
                            @"lastName"  : @"Smith",
                            @"rating"    : @5 };
    
    Person *fred = [[Person alloc] init];
    [fred setValuesForKeysWithDictionary:info];
    NSLog(@"%@", fred);
}

- (void)testKVCWithArray {
    NSArray *dicts = @[
        @{ @"firstName" : @"Fred", @"lastName" : @"Smith", @"rating" : @4 },
        @{ @"firstName" : @"Barb", @"lastName" : @"Jones", @"rating" : @5 }
    ];
    
    NSMutableArray *peeps = [NSMutableArray array];
    for (NSDictionary *dict in dicts) {
        Person *newPerson = [[Person alloc] init];
        [newPerson setValuesForKeysWithDictionary:dict];
        [peeps addObject:newPerson];
    }
    NSLog(@"%@", peeps);
}


@end
