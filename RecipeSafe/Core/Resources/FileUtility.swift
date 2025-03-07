//
//  FileUtility.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/17/24.
//

import Foundation
import UIKit

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
    
    static func compressImage(image: UIImage, toSize size: Int, jpegCompressionQuality: CGFloat = 0.25) -> Data? {
        var newImage: UIImage? = image
        
        var data = newImage?.jpegData(compressionQuality: jpegCompressionQuality)
        
        while data != nil && data?.count ?? 0 > size {
            newImage = UIImage(data: data!)?.resized(sizeReduce: 0.5)
            data = newImage?.jpegData(compressionQuality: jpegCompressionQuality)
        }
        
        return data
    }
}

extension UIImage {
    func resized(sizeReduce: CGFloat, isOpaque: Bool = false) -> UIImage? {
        let canvas = CGSize(width: size.width * sizeReduce, height: size.height * sizeReduce)
        let format = imageRendererFormat
        format.opaque = isOpaque
        
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
