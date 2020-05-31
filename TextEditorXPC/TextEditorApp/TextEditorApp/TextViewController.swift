// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

import Cocoa
import TextServiceInterface

class TextViewController: NSViewController
{
    @IBOutlet private var textView: NSTextView!

    var textService: TextServiceProtocol?
    let xpcConnection = NSXPCConnection(serviceName: TextServiceName)
    
    // TODO: it would be better for a window controller to own the connection and invalidate it
    // when the window closes.
    deinit {
        xpcConnection.invalidate()
    }
}

// MARK: - Action methods
extension TextViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextService()
        // Warm up the service
        textService?.ping()
    }
    
    @IBAction func changeCase(_ control: NSSegmentedControl) {
        let text = textView.string
        switch control.selectedSegment {
            case 0: textService?.uppercased(text) { [weak self] updatedText in
                OperationQueue.main.addOperation { self?.textView.string = updatedText }
            }
            case 1: textService?.capitalized(text) { [weak self] updatedText in
                OperationQueue.main.addOperation { self?.textView.string = updatedText }
            }
            case 2: textService?.lowercased(text) { [weak self] updatedText in
                OperationQueue.main.addOperation { self?.textView.string = updatedText }
            }
            default: break
        }
    }
}

extension TextViewController
{
    private func configureTextService() {
        xpcConnection.remoteObjectInterface = NSXPCInterface(with: TextServiceProtocol.self)
        xpcConnection.resume()
        
        let errorHandler = { error in
            OperationQueue.main.addOperation { [weak self] in self?.presentError(error) }
        }
        
        textService = xpcConnection.remoteObjectProxyWithErrorHandler(errorHandler) as? TextServiceProtocol
        
        if textService == nil {
            assertionFailure("Unable to configure text service with connection \(self.xpcConnection)")
            return
        }
    }
}
