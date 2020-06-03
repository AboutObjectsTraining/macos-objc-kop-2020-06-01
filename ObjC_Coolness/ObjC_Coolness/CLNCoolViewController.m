// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import "CLNCoolViewController.h"
#import "CLNCoolViewCell.h"
#import "CLNAppDelegate.h"
#import "CLNInspectorViewController.h"

@interface CLNCoolViewController ()
@property (strong, nonatomic) IBOutlet NSBox *box;
@property (readonly, nonatomic) CLNInspectorViewController *panelController;
@end

@implementation CLNCoolViewController

- (CLNInspectorViewController *)panelController {
    return ((CLNAppDelegate *)NSApp.delegate).inspectorViewController;
}

- (IBAction)addCell:(id)sender {
    CLNCoolViewCell *cell = [[CLNCoolViewCell alloc] init];
    cell.text = self.panelController.textField.stringValue;
    cell.backgroundColor = NSColor.systemBrownColor;
    
    [self.box addSubview:cell];
}

@end
