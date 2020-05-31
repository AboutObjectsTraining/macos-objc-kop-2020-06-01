// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

import Foundation
import TextServiceInterface

public class TextService: NSObject, TextServiceProtocol
{
    public func uppercased(_ text: String, completion: @escaping (String) -> Void) {
        completion(text.uppercased())
    }
    
    public func lowercased(_ text: String, completion: @escaping (String) -> Void) {
        completion(text.lowercased())
    }
    
    public func capitalized(_ text: String, completion: @escaping (String) -> Void) {
        completion(text.capitalized)
    }
    
    public func ping() {
        print("\(self): received ping")
    }
}
