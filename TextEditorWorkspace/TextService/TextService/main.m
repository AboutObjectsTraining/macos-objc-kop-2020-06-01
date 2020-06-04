// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <Foundation/Foundation.h>
#import "TXTTextServiceDelegate.h"

int main(int argc, const char *argv[])
{
    NSXPCListener *listener = [NSXPCListener serviceListener];
    TXTTextServiceDelegate *delegate = [TXTTextServiceDelegate new];
    listener.delegate = delegate;
    
    // Resuming the serviceListener starts this service. This method does not return.
    [listener resume];
    return 0;
}
