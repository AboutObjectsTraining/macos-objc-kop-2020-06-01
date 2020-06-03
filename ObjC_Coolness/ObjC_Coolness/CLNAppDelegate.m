// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import "CLNAppDelegate.h"

@interface CLNAppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation CLNAppDelegate

- (IBAction)showInspectorPanel:(id)sender {
    if (self.inspectorPanel == nil) {
        [NSBundle.mainBundle loadNibNamed:@"InspectorPanel" owner:self topLevelObjects:nil];
    }
    [self.inspectorPanel orderFront:nil];
}

- (IBAction)showMainWindow:(id)sender {
    [self.window orderFront:nil];
}

@end
