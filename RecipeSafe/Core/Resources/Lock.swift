//
//  Lock.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/20/25.
//

import Foundation

final class Lock<Value>: Sendable where Value: Sendable {
    
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    private nonisolated(unsafe) var _oslock = os_unfair_lock_s()

    @inline(__always)
    private func _lock() {
        os_unfair_lock_lock(&_oslock)
    }

    @inline(__always)
    private func _unlock() {
        os_unfair_lock_unlock(&_oslock)
    }
    #else
    private let _nslock = NSLock()

    @inline(__always)
    private func _lock() {
        _nslock.lock()
    }

    @inline(__always)
    private func _unlock() {
        _nslock.unlock()
    }
    #endif
    
    private nonisolated(unsafe) var _value: Value
    private let onDeinit: @Sendable (Value) -> Void
    
    deinit {
        onDeinit(_value)
    }
    
    var value: Value {
        _lock()
        defer { _unlock() }
        
        return _value
    }
    
    var unsafeValue: Value {
        get {
            _value
        }
        set {
            _value = newValue
        }
    }
    
    func unsafeLock() {
        _lock()
    }
    
    func unlock() {
        _unlock()
    }
    
    func set(_ newValue: Value) {
        _lock()
        defer { _unlock() }
        
         _value = newValue
    }
    
    func modify<T>(_ transform: (inout Value) -> T) -> T {
        _lock()
        defer { _unlock() }
        
        return transform(&_value)
    }
    
    init(_ value: Value) {
        self._value = value
        self.onDeinit = { _ in }
    }
    
    init(_ value: Value, onDeinit: @Sendable @escaping (Value) -> Void) {
        self._value = value
        self.onDeinit = onDeinit
    }
}
