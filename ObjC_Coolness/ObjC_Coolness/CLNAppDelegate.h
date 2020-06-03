// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Cocoa/Cocoa.h>
#import "CLNCoolViewController.h"
#import "CLNInspectorViewController.h"

@interface CLNAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) IBOutlet CLNCoolViewController *coolController;
@property (strong, nonatomic) IBOutlet NSPanel *inspectorPanel;
@property (strong, nonatomic) IBOutlet CLNInspectorViewController *inspectorViewController;

@end

