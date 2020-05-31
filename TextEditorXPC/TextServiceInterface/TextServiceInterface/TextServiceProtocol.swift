// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

import Foundation

public let TextServiceName = "com.aboutobjects.training.TextService"

@objc public protocol TextServiceProtocol
{
    func uppercased(_ text: String, completion: @escaping (String) -> Void)
    func lowercased(_ text: String, completion: @escaping (String) -> Void)
    func capitalized(_ text: String, completion: @escaping (String) -> Void)
    
    func ping()
}
