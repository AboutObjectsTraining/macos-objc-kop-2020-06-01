// See LICENSE folder for this sample’s licensing information.
// Abstract: This file contains the implementation of the primary NSViewController class.

import Cocoa
import NetworkExtension
import SystemExtensions
import os.log

extension NSImage {
    static var redDot = NSImage(named: "dot_red")
    static var yellowDot = NSImage(named: "dot_yellow")
    static var greenDot = NSImage(named: "dot_green")
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()


/// The FirewallViewController class is responsible for the management of UI-based app behaviors, including:
///   - Activating the system extension and enabling the content filter configuration when the user clicks on the Start button
///   - Disabling the content filter configuration when the user clicks on the Stop button
///   - Prompting the user to allow or deny connections at the behest of the system extension
///   - Logging connections in a NSTextView
class FirewallViewController: NSViewController
{
    enum Status {
        case stopped
        case indeterminate
        case running
    }
    
    @IBOutlet var statusIndicator: NSImageView!
    @IBOutlet var statusSpinner: NSProgressIndicator!
    @IBOutlet var startButton: NSButton!
    @IBOutlet var stopButton: NSButton!
    @IBOutlet var logTextView: NSTextView!

    var observer: Any?

    var status: Status = .stopped {
        didSet {
            // Update the UI to reflect the new status
            switch status {
                case .stopped:
                    statusIndicator.image = NSImage.redDot
                    statusSpinner.stopAnimation(self)
                    statusSpinner.isHidden = true
                    stopButton.isHidden = true
                    startButton.isHidden = false
                case .indeterminate:
                    statusIndicator.image = NSImage.yellowDot
                    statusSpinner.startAnimation(self)
                    statusSpinner.isHidden = false
                    stopButton.isHidden = true
                    startButton.isHidden = true
                case .running:
                    statusIndicator.image = NSImage.greenDot
                    statusSpinner.stopAnimation(self)
                    statusSpinner.isHidden = true
                    stopButton.isHidden = false
                    startButton.isHidden = true
            }
            
            if !statusSpinner.isHidden {
                statusSpinner.startAnimation(self)
            } else {
                statusSpinner.stopAnimation(self)
            }
        }
    }

    // Get the Bundle of the system extension.
    lazy var extensionBundle: Bundle = {

        let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
        let extensionURLs: [URL]
        do {
            extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
        } catch {
            fatalError("Failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
        }
        guard let extensionURL = extensionURLs.first else { fatalError("Failed to find any system extensions") }
        guard let extensionBundle = Bundle(url: extensionURL) else { fatalError("Failed to create a bundle with URL \(extensionURL.absoluteString)") }
        return extensionBundle
    }()

    // MARK: - Overridden NSViewController methods
    override func viewWillAppear() {
        super.viewWillAppear()
        status = .indeterminate
        loadFilterConfiguration { didLoad in
            guard didLoad else {
                self.status = .stopped
                return
            }
            self.filterConfigurationDidChange()
            self.observer = NotificationCenter.default.addObserver(forName: .NEFilterConfigurationDidChange,
                                                                   object: NEFilterManager.shared(),
                                                                   queue: .main) { [weak self] _ in self?.filterConfigurationDidChange() }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        guard let observer = observer else {
            return
        }
        NotificationCenter.default.removeObserver(observer, name: .NEFilterConfigurationDidChange, object: NEFilterManager.shared())
    }
    
    // MARK: - Updating the UI
    func filterConfigurationDidChange() {
        if NEFilterManager.shared().isEnabled {
            connectToFirewall()
        } else {
            status = .stopped
        }
    }

    func presentFlowInfo(_ flowInfo: [String: String], at date: Date, userAllowed: Bool) {
        guard let localPort = flowInfo[EndpointKeys.localPort],
            let remoteAddress = flowInfo[EndpointKeys.remoteAddress],
            let font = NSFont.userFixedPitchFont(ofSize: 12.0) else {
                return
        }

        let dateString = dateFormatter.string(from: date)
        let message = "\(dateString) \(userAllowed ? "ALLOW" : "DENY") \(localPort) <-- \(remoteAddress)\n"
        os_log("%@", message)

        let logAttributes: [NSAttributedString.Key: Any] = [ .font: font, .foregroundColor: NSColor.textColor ]
        let attributedString = NSAttributedString(string: message, attributes: logAttributes)
        logTextView.textStorage?.append(attributedString)
    }

    // MARK: - Action methods
    
    @IBAction func startFilter(_ sender: Any) {
        status = .indeterminate
        guard !NEFilterManager.shared().isEnabled else {
            connectToFirewall()
            return
        }

        guard let extensionIdentifier = extensionBundle.bundleIdentifier else {
            self.status = .stopped
            return
        }

        // Start by activating the system extension
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }

    @IBAction func stopFilter(_ sender: Any) {
        let filterManager = NEFilterManager.shared()
        status = .indeterminate
        guard filterManager.isEnabled else {
            status = .stopped
            return
        }

        loadFilterConfiguration { didLoad in
            guard didLoad else {
                self.status = .running
                return
            }
                        
            // Disable the content filter configuration
            filterManager.isEnabled = false
            
            filterManager.saveToPreferences { error in
                DispatchQueue.main.async {
                    if let error = error {
                        os_log("Failed to disable the filter configuration: %@", error.localizedDescription)
                        self.status = .running
                        return
                    }
                    self.status = .stopped
                }
            }
        }
    }

    // MARK: - Content filter configuration
    func loadFilterConfiguration(completionHandler: @escaping (Bool) -> Void) {
        NEFilterManager.shared().loadFromPreferences { error in
            DispatchQueue.main.async {
                var didLoad = true
                if let error = error {
                    os_log("Failed to load the filter configuration: %@", error.localizedDescription)
                    didLoad = false
                }
                completionHandler(didLoad)
            }
        }
    }
    
    var providerConfiguration: NEFilterProviderConfiguration {
        let configuration = NEFilterProviderConfiguration()
        configuration.filterSockets = true
        configuration.filterPackets = false
        return configuration
    }

    func enableFilterConfiguration() {
        let filterManager = NEFilterManager.shared()
        guard !filterManager.isEnabled else {
            connectToFirewall()
            return
        }
        
        // TODO: Refactor
        loadFilterConfiguration { didLoad in
            guard didLoad else {
                self.status = .stopped
                return
            }

            if filterManager.providerConfiguration == nil {
                filterManager.providerConfiguration = self.providerConfiguration
                if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                    filterManager.localizedDescription = appName
                }
            }

            filterManager.isEnabled = true

            filterManager.saveToPreferences { error in
                DispatchQueue.main.async {
                    if let error = error {
                        os_log("Failed to save the filter configuration: %@", error.localizedDescription)
                        self.status = .stopped
                        return
                    }
                    self.connectToFirewall()
                }
            }
        }
    }
    
    // MARK: - Connecting to the firewall
    func connectToFirewall() {
        FirewallManager.shared.establishConnection(extensionBundle: extensionBundle, controller: self) { isConnected in
            DispatchQueue.main.async {
                self.status = (isConnected ? .running : .stopped)
            }
        }
    }
}

// MARK: - OSSystemExtensionRequestDelegate
extension FirewallViewController: OSSystemExtensionRequestDelegate
{
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        guard result == .completed else {
            os_log("Unexpected result %d for system extension request", result.rawValue)
            status = .stopped
            return
        }
        enableFilterConfiguration()
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        os_log("System extension request failed: %@", error.localizedDescription)
        status = .stopped
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        os_log("Extension %@ requires user approval", request.identifier)
    }

    func request(_ request: OSSystemExtensionRequest,
                 actionForReplacingExtension existing: OSSystemExtensionProperties,
                 withExtension extension: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        os_log("Replacing extension %@ version %@ with version %@", request.identifier, existing.bundleShortVersion, `extension`.bundleShortVersion)
        return .replace
    }
}

// MARK: - FirewallViewControllerProtocol
extension FirewallViewController: FirewallViewControllerProtocol
{
    func handleNewFlow(flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void) {
        guard let localPort = flowInfo[EndpointKeys.localPort],
            let remoteAddress = flowInfo[EndpointKeys.remoteAddress],
            let window = view.window else {
                os_log("Got a promptUser call without valid flow info: %@", flowInfo)
                responseHandler(true)
                return
        }

        let connectionDate = Date()

        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "New incoming connection"
            alert.informativeText = "A new connection on port \(localPort) has been received from \(remoteAddress)."
            alert.addButton(withTitle: "Allow")
            alert.addButton(withTitle: "Deny")

            alert.beginSheetModal(for: window) { userResponse in
                let userAllowed = (userResponse == .alertFirstButtonReturn)
                self.presentFlowInfo(flowInfo, at: connectionDate, userAllowed: userAllowed)
                responseHandler(userAllowed)
            }
        }
    }
}
