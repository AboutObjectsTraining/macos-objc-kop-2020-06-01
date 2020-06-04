// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <TextServiceAPI/TextServiceAPI.h>
#import "TXTTextServiceDelegate.h"
#import "TXTTextService.h"

@implementation TXTTextServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(TXTTextServiceProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    newConnection.exportedObject = [[TXTTextService alloc] init];
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    return YES;
}


@end
