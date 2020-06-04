// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import <TextServiceAPI/TextServiceAPI.h>
#import "TXTEditorViewController.h"

@interface TXTEditorViewController ()

@property (strong, nonatomic) IBOutlet NSTextView *textView;

@property (strong, nonatomic) id<TXTTextServiceProtocol> textService;
@property (strong, nonatomic) NSXPCConnection *connection;

@end


@implementation TXTEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTextService];
    
    [self.textService ping];
}

- (void)configureTextService {
    self.connection = [[NSXPCConnection alloc] initWithServiceName:TXTTextServiceName];
    self.connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(TXTTextServiceProtocol)];
    [self.connection resume];
    
    self.textService = [self.connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{ [self presentError:error]; }];
    }];
}

- (IBAction)changeCase:(NSSegmentedControl *)sender {
    NSString *text = self.textView.string;
    [self.textService uppercaseString:text completionHandler:^(NSString *responseText) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.textView.string = responseText; }];
    }];
}

@end
