//
//  GPTSocket.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/26/23.
//

import Foundation
import Combine

class GPTSocket: NetworkProtocol {
    
    var session: URLSession
    var cancellable: AnyCancellable?
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func testNewGPT() {
        let request = GPTRequest()
        cancellable = executeRequest(request: request, decodeType: GPTResponse.self, retries: 0).sink {
            print($0)
        } receiveValue: { response in
            print(response)
        }
    }
}


