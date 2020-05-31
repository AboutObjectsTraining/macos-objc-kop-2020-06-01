// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Foundation/Foundation.h>

@import Foundation;
@import TextServiceInterface;

#import "TextService-Swift.h"

int main(int argc, const char *argv[])
{
    TextServiceDelegate *delegate = [TextServiceDelegate new];
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    
    [listener resume];
    return 0;
}
