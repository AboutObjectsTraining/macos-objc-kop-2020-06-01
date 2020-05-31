// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

import Foundation
import TextServiceInterface

class TextServiceDelegate: NSObject, NSXPCListenerDelegate
{
    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool
    {
        // Expose the service API
        newConnection.exportedInterface = NSXPCInterface(with: TextServiceProtocol.self)
        
        // Configure an object to handle requests
        let exportedObject = TextService()
        newConnection.exportedObject = exportedObject
        
        // Start the run loop
        newConnection.resume()
        return true
    }
}
