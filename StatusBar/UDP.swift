//
//  UDP.swift
//  StatusBar
//
//  Created by Havil on 20.05.2020.
//  Copyright © 2020 Havil. All rights reserved.
//

import Foundation
import Network

class StateServerHelper {
    
    struct State: Codable {
        let power: Bool
    }
    
    func getState(data: Data) -> State {
        let state = try! JSONDecoder().decode(State.self, from: data)
        return state
    }
    
}

class UDP {
    
    private var connection: NWConnection? = nil
    
    init(
        ip: String,
        port: UInt16,
        onSuccess: @escaping ( StateServerHelper.State? ) -> Void)
    {
        connection = NWConnection(host: NWEndpoint.Host(ip), port: NWEndpoint.Port(rawValue: port)!, using: .udp)
        /*connection?.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .ready:
                print("ready")
            case .setup:
                print("setup")
            case .cancelled:
                print("cancelled")
            case .preparing:
                print("Preparing")
            default:
                print("waiting or failed")
                break
            }
        }*/
        connection?.start(queue: .global())
        receive(onSuccess: onSuccess)
    }
    
    func receive(onSuccess: @escaping ( StateServerHelper.State? ) -> Void) {
        connection?.receiveMessage { (data, context, isComplete, error) in
            if let data = data {
                let stateServerHelper = StateServerHelper()
                let state = stateServerHelper.getState(data: data)
                onSuccess(state)
            }
            //onSuccess(String(data: data!, encoding: String.Encoding.utf8) as String?)
            self.receive(onSuccess: onSuccess)
        }
    }
    
    func send(
        key: String,
        value: String,
        onError: @escaping ( String ) -> Void)
    {
        let data: Data? = "{key: '\(key)', value: '\(value)'}".data(using: .utf8)
        connection!.send(content: data, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                onError(error.debugDescription)
            }
        }))
    }
    
}

