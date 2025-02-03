//
//  Service.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/3/24.
//

import Foundation

@propertyWrapper
final class Service<T> {
    private lazy var _wrappedValue: T? = ServiceRegister.shared.resolveTaggedService()
    
    var wrappedValue: T? {
        get { _wrappedValue }
    }
}

final class ServiceRegister: @unchecked Sendable {
    typealias ServiceFactory = () -> Any
    private var factories = [String: ServiceFactory]()
    private var weakInstances = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    static let shared = ServiceRegister()
    
    private init() {}
}

extension ServiceRegister {
    
    fileprivate func resolveTaggedService<T>() -> T? {
        let key = ServiceRegister.serviceName(of: T.self)
        
        if !(T.self is AnyClass) {
            return factories[key]?() as? T
        }

        if let instance = weakInstances.object(forKey: key as NSString) {
            return instance as? T
        }
        guard let obj = factories[key]?() as? T else {
            return nil
        }
        weakInstances.setObject(obj as AnyObject, forKey: key as NSString)
        return obj
    }
    
    static func addService<T>(_ service: @autoclosure @escaping () -> T) {
        shared.factories[serviceName(of: T.self)] = service
    }
    
    private static func serviceName<T>(of service: T) -> String {
        "\(type(of: service))"
    }
}
