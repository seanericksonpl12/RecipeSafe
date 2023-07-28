//
//  GPTSocket.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/26/23.
//

import Foundation
import Combine
import SwiftSoup
import SwiftyJSON

// MARK: - TEST CLASS ONLY
class GPTSocket: NetworkProtocol {
    
    var session: URLSession
    var cancellable: AnyCancellable?
    var cancellables: Set<AnyCancellable> = []
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func testNewGPT() {
        let request = URLRequest(url: URL(string: "https://www.inspiredtaste.net/38940/spaghetti-with-meat-sauce-recipe/")!)
        getHTML(request: request, retries: 0).sink {
            print($0)
        } receiveValue: { [weak self] html in
            guard let self = self else { return }
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let scripts = try doc.select("script[type=application/ld+json]").first()?.data()
                guard let jsonData = scripts?.data(using: .utf8, allowLossyConversion: false) else { return }
                
                let json = try JSON(data: jsonData).rawString(.utf8, options: [])
                if let jsonString = json {
                   
                    var newRequest = GPTRequest()
                    newRequest.messages = [
                        ["role": "system", "content": "The user will give you JSON representing a recipe, you will tell them the title, ingredients, instructions, description, thumbnail, cook time, and prep time of the recipe in json format using keys \"title\", \"ingredients\", \"instructions\", \"description\", \"thumbnail\", \"cook_time\", \"prep_time\""],
                        ["role": "user", "content": "Here is the json: \(jsonString)"]
                    ]
                    executeRequest(request: newRequest, retries: 0).sink {
                        print($0)
                    } receiveValue: {
                        print($0)
                    }.store(in: &self.cancellables)
                }
            } catch {
                print("scraping failed")
            }
        }.store(in: &cancellables)
    }
    
    func testRequest(_ request: GPTRequest) {
        cancellable = executeRequest(request: request, retries: 0).sink {
            print($0)
        } receiveValue: {
            print($0)
        }
    }
}


