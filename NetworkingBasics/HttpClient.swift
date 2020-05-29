// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

import OSLog
import Foundation
import Network

open class HttpClient
{
    public let hostname: String
    public let port: NWEndpoint.Port
    public let endpoint: NWEndpoint
    public let connection: NWConnection
    
    public var resultHandler: ((Result<Data?, Error>) -> Void)? {
        didSet {
            if let resultHandler = resultHandler {
                receive(resultHandler: resultHandler)
            }
        }
    }
    
    public init(hostname: String, port: NWEndpoint.Port) throws {
        self.hostname = hostname
        self.port = port
        endpoint = NWEndpoint.hostPort(host: .name(hostname, nil), port: port)
        connection = NWConnection(to: endpoint, using: .tcp)
        showConnectionStatus()
    }
    
    open func showConnectionStatus() {
        connection.stateUpdateHandler = { state in
            var statusText = ""
            switch state {
                case .ready:              statusText = "succeeded!"
                case .waiting(let error): statusText = "is waiting with error: \(error)"
                case .failed(let error):  statusText = "failed with error: \(error)"
                case .cancelled:          statusText = "cancelled."
                default: break
            }
            os_log("Connection to %s %s", self.endpoint.debugDescription, statusText)
        }
    }
    
    open func receive(resultHandler: @escaping (Result<Data?, Error>) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
            (data: Data?, context: NWConnection.ContentContext?, completed: Bool, error: NWError?) in
            os_log("\n*** Received data with byte count: %d ***\n", data?.count ?? 0)
            guard let data = data else {
                os_log("Empty result")
                resultHandler(Result.failure(error ?? NSError()))
                return
            }
            resultHandler(Result.success(data))
        }
    }

    open func start() {
        self.connection.start(queue: DispatchQueue.global())
    }
    
    open func read(requestText: String) {
        let data = requestText.data(using: .utf8)
        connection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                os_log("Send failed with error %s", error.debugDescription)
                return
            }
            os_log("Connection sent data with count: %s, text: '%s'", data?.description ?? "null", requestText)
        }))
    }
}
