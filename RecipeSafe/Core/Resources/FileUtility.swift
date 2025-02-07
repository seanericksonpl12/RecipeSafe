//
//  FileUtility.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/17/24.
//

import Foundation

struct FileUtility {
    
    private static let decoder = JSONDecoder()
    
    enum FileType: String {
        case json
        case text = "txt"
    }
    
    static func read<T: Codable>(name: String, type: FileType, model: T.Type) -> T? {
        guard let path = Bundle.main.path(forResource: name, ofType: type.rawValue) else  {
            print("Bad Path!")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(filePath: path), options: .mappedIfSafe)
            let file = try decoder.decode(model, from: data)
            return file
        } catch {
            print("error reading file!\nPath: \(path)\nType: \(type.rawValue)\nError: \(error)")
            return nil
        }
    }
    
    static func readRawJson(name: String) -> Dictionary<String, AnyObject>? {
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else  {
            print("Bad Path!")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(filePath: path), options: .mappedIfSafe)
            let file = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            return file as? Dictionary<String, AnyObject>
        } catch {
            print("error reading file!\nPath: \(path)\nError: \(error)")
            return nil
        }
    }
    
    static func fetchPlist(name: String) throws -> [String: String] {
        let path = Bundle.main.path(forResource: name, ofType: "plist")!
        let url = URL(filePath: path)
        let data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode([String: String].self, from: data)
    }
}
