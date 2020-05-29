// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

import XCTest
import Network

@testable import NetworkingBasics

class NetworkTests: XCTestCase
{
    var connection: NWConnection!

    override func setUpWithError() throws {
        // "199.193.192.13"
        let endpoint = NWEndpoint.hostPort(host: .name("www.google.com", nil), port: .http) // https://www.aboutobjects.com
        connection = NWConnection(to: endpoint, using: .tcp)
        connection.stateUpdateHandler = { state in
            switch state {
                case .ready: print("Connection to \(endpoint) succeeded!")
                case .waiting(let error): print("Connection to \(endpoint) is waiting with error: \(error)...")
                case .failed(let error):  print("Connection to \(endpoint) failed with error: \(error).")
                case .cancelled: print("Connection to \(endpoint) cancelled.")
                default: break
            }
        }
    }

    override func tearDownWithError() throws {
        connection = nil
    }

    func testReadFromConnection() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
            (data: Data?, context: NWConnection.ContentContext?, completed: Bool, error: NWError?) in
            print("\n*** Received something! ***\n")
        }
//        connection.receiveMessage { (data: Data?, context: NWConnection.ContentContext?, completed: Bool, error: NWError?) in
//            print("Received message...")
//            guard let text = data?.base64EncodedString() else {
//                if let context = context { print(context.identifier) }
//                return
//            }
//            print(text)
//        }
        
        connection.start(queue: DispatchQueue.global())
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        connection.requestEstablishmentReport(queue: DispatchQueue.main) { (report: NWConnection.EstablishmentReport?) in
            print(report ?? "Empty report")
        }
        
        connection.send(content: nil, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({ error in
            print("sendEndOfStream")
            if let error = error {
                //self.connectionDidFail(error: error)
                print("sendEndOfStream: error \(error.localizedDescription)")
            }
        }))
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
    }

    func testReadFromConnectionSendingGetRequest() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
            (data: Data?, context: NWConnection.ContentContext?, completed: Bool, error: NWError?) in
            print("\n*** Received something -- data is \(data?.description ?? "null") ***\n")
            if let data = data {
                print(String(data: data, encoding: .utf8) ?? "empty")
            }
        }
        
        connection.start(queue: DispatchQueue.global())
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        
        let data = "GET /\r\n".data(using: .utf8)
        connection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                print("Send failed with error \(error)")
                return
            }
            print("connection did send, data: \(data?.description ?? "null")")
        }))

        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        connection.requestEstablishmentReport(queue: DispatchQueue.main) { (report: NWConnection.EstablishmentReport?) in
            print(report ?? "Empty report")
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
    }
    
    func testFetchURLFromClient() {
        let expectation = XCTestExpectation(description: "Completion closure should have been executed.")
        
        let client = try! HttpClient(hostname: "www.google.com", port: .http)
        
        client.resultHandler = { result in
            switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        print(String(data: data!, encoding: .utf8)!)
                    }
                    expectation.fulfill()
                case .failure(let error):
                    print(error)
            }
        }
        
        client.start()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        
        client.read(requestText: "GET /\r\n")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.5))
        
        wait(for: [expectation], timeout: 3)
    }
}
