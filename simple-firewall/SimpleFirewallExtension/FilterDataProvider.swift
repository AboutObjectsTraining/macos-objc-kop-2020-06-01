// See LICENSE folder for this sample’s licensing information.
// Abstract: This file contains the implementation of the NEFilterDataProvider sub-class.

import NetworkExtension
import os.log

/// The TCP port the filter should monitor
private let localPort = "8888"

/// A FilterDataProvider object monitors connection attempts that match the installed rules and prompts
/// the user to allow or deny the connections.
class FilterDataProvider: NEFilterDataProvider
{
    var filterRules: [NEFilterRule] = {
        let rules = ["0.0.0.0", "::"].map { address -> NEFilterRule in
            let localNetwork = NWHostEndpoint(hostname: address, port: localPort)
            let inboundNetworkRule = NENetworkRule(remoteNetwork: nil,
                                                   remotePrefix: 0,
                                                   localNetwork: localNetwork,
                                                   localPrefix: 0,
                                                   protocol: .TCP,
                                                   direction: .inbound)
            return NEFilterRule(networkRule: inboundNetworkRule, action: .filterData)
        }
        return rules
    }()
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        os_log("Starting filter with port number %s", localPort)
        // Allow all flows that do not match the filter rules.
        let filterSettings = NEFilterSettings(rules: filterRules, defaultAction: .allow)

        apply(filterSettings) { error in
            if let error = error { os_log("Failed to apply filter settings: %@", error.localizedDescription) }
            completionHandler(error)
        }
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        guard
            let socketFlow = flow as? NEFilterSocketFlow,
            let remoteEndpoint = socketFlow.remoteEndpoint as? NWHostEndpoint,
            let localEndpoint = socketFlow.localEndpoint as? NWHostEndpoint else {
                return .allow()
        }
        os_log("Got a new flow with local endpoint %@, remote endpoint %@", localEndpoint, remoteEndpoint)
        
        let flowInfo = [
            EndpointKeys.localPort: localEndpoint.port,
            EndpointKeys.remoteAddress: remoteEndpoint.hostname
        ]

        // Ask the app to prompt the user
        let prompted = FirewallManager.shared.handleNewFlow(flowInfo: flowInfo) { shouldAllow in
            let userVerdict: NEFilterNewFlowVerdict = shouldAllow ? .allow() : .drop()
            self.resumeFlow(flow, with: userVerdict)
        }
        
        return prompted ? .pause() : .allow()
    }
}
