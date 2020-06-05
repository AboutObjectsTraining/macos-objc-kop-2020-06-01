// See LICENSE folder for this sample’s licensing information.
// Abstract: This file contains the implementation of the app <-> provider IPC connection

import Foundation
import os.log
import Network

// MARK: - Custom communication protocols

/// Adopted by the FirewallManager to enable XPC communication from the FirewallViewController
@objc protocol FirewallManagerProtocol {
    func establishConnection(extensionBundle bundle: Bundle, controller: FirewallViewControllerProtocol, completionHandler: @escaping (Bool) -> Void)
    func didEstablishConnection(_ completionHandler: @escaping (Bool) -> Void)
}

/// Adopted by the FirewallViewController to enable XPC communication from the FirewallManager
@objc protocol FirewallViewControllerProtocol {
    func handleNewFlow(flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void)
}

struct EndpointKeys {
    static let localPort = "localPort"
    static let remoteAddress = "remoteAddress"
}

// MARK: - FirewallManager class

/// The FirewallManager class is used by both the app and the system extension to communicate with one another
class FirewallManager: NSObject
{
    // MARK: Stored properties
    var listener: NSXPCListener?
    var xpcConnection: NSXPCConnection?
    weak var firewallViewController: FirewallViewControllerProtocol?
    static let shared = FirewallManager()

    // MARK: Methods

    /// The NetworkExtension framework registers a Mach service with the name in the system extension's NEMachServiceName Info.plist key.
    /// The Mach service name must be prefixed with one of the app groups in the system extension's com.apple.security.application-groups entitlement.
    /// Any process in the same app group can use the Mach service to communicate with the system extension.
    private func extensionMachServiceName(from bundle: Bundle) -> String {
        guard
            let keys = bundle.object(forInfoDictionaryKey: "NetworkExtension") as? [String: Any],
            let name = keys["NEMachServiceName"] as? String
            else {
                fatalError("Mach service name is missing from the Info.plist")
        }
        return name
    }

    func startListener() {
        let machServiceName = extensionMachServiceName(from: Bundle.main)
        os_log("Starting XPC listener for mach service %@", machServiceName)

        let newListener = NSXPCListener(machServiceName: machServiceName)
        newListener.delegate = self
        newListener.resume()
        listener = newListener
    }

    /// Called by the FirewallViewController to connect to the FilterDataProvider.
    func establishConnection(extensionBundle bundle: Bundle, controller: FirewallViewControllerProtocol, completionHandler: @escaping (Bool) -> Void) {
        self.firewallViewController = controller

        guard xpcConnection == nil else {
            os_log("Already connected to the provider")
            completionHandler(true)
            return
        }
        
        // Name in Info.plist used to look up the filter data provider
        let machServiceName = extensionMachServiceName(from: bundle)
        let newConnection = NSXPCConnection(machServiceName: machServiceName, options: [])

        newConnection.exportedInterface = NSXPCInterface(with: FirewallViewControllerProtocol.self)
        newConnection.exportedObject = controller
        newConnection.remoteObjectInterface = NSXPCInterface(with: FirewallManagerProtocol.self)

        xpcConnection = newConnection
        newConnection.resume()
        
        let proxy = newConnection.remoteObjectProxyWithErrorHandler { error in
            os_log("Failed to connect to the provider: %@", error.localizedDescription)
            self.xpcConnection?.invalidate()
            self.xpcConnection = nil
            completionHandler(false)
        }

        guard let connectionManager = proxy as? FirewallManagerProtocol else {
            fatalError("Failed to create a remote object proxy for the provider")
        }
        
        connectionManager.didEstablishConnection(completionHandler)
    }


    /// Called by the FilterDataProvider to cause the FirewallViewController (if it is connected) to prompt the user
    /// to allow the connection.
    func handleNewFlow(flowInfo: [String: String], responseHandler:@escaping (Bool) -> Void) -> Bool {
        guard let connection = xpcConnection else {
            os_log("Cannot prompt user because the app isn't connected")
            return false
        }
        
        let proxy = connection.remoteObjectProxyWithErrorHandler { promptError in
            os_log("Failed to prompt the user: %@", promptError.localizedDescription)
            self.xpcConnection = nil
            responseHandler(true)
        }
        
        guard let viewController = proxy as? FirewallViewControllerProtocol else {
            fatalError("Failed to create a remote object proxy for the FirewallViewController")
        }

        viewController.handleNewFlow(flowInfo: flowInfo, responseHandler: responseHandler)
        
        return true
    }
}

// MARK:  - NSXPCListenerDelegate
extension FirewallManager: NSXPCListenerDelegate
{
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: FirewallManagerProtocol.self)
        newConnection.exportedObject = self
        newConnection.remoteObjectInterface = NSXPCInterface(with: FirewallViewControllerProtocol.self)
        
        newConnection.invalidationHandler = { self.xpcConnection = nil }
        newConnection.interruptionHandler = { self.xpcConnection = nil }
        
        xpcConnection = newConnection
        newConnection.resume()
        
        return true
    }
}

// MARK: - FirewallManagerProtocol
extension FirewallManager: FirewallManagerProtocol
{
    func didEstablishConnection(_ completionHandler: @escaping (Bool) -> Void) {
        os_log("FirewallViewController established a connection to the system extension")
        completionHandler(true)
    }
}
