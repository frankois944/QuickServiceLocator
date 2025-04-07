//
//  QuickServiceLocator.swift
//
//  Created by François Dabonot on 18/01/2024.
//

import Foundation

/// Loading way of a registered service
public enum LocatingMode {
    /// load a new instance of the service each time
    case newInstance
    /// load the service in a singleton when it's required
    case lazySharedInstance
    /// load the service in a singleton when registered
    case sharedInstance
}

public struct QuickServiceLocator {
    
    // MARK: - Properties
    
    private static var factories: [ObjectIdentifier: (LocatingMode, () -> Any)] = [:]
    private static var sharedInstances: [ObjectIdentifier: Any] = [:]
    
    // MARK: - Register
    
    /// Register a service and possibly customize the behavior of the service by setting the mode
    ///
    /// ```swift
    /// QuickServiceLocator.register(DummyServiceProtocol.self, 
    ///                                 mode: .newInstance,
    ///                                 DummyService())
    /// ```
    ///
    /// - Parameters:
    ///   - type: The type of the service
    ///   - mode: The behavior of the registered service (default: lazySharedInstance)
    ///   - factory: the `constructor` of the service
    public static func register<T>(_ type: T.Type,
                            mode: LocatingMode = .lazySharedInstance,
                            _ factory: @autoclosure @escaping () -> T) {
        self.factories[ObjectIdentifier(type)] = (mode, factory)
        if mode == .sharedInstance {
           self.locate(type)
        }
    }
    
    // MARK: - Resolver
    
    /// Resolve a service from result type
    ///
    /// ```swift
    /// let service: DummyServiceProtocol = QuickServiceLocator.locate()
    /// ```
    /// - Remark: Resolving an unregistered service will make the application crash
    /// - Returns: The instance of the service
    public static func locate<T>() -> T {
        return locate(T.self)
    }

    /// Resolve a service from parameter Type
    ///
    /// ```swift
    /// let service = QuickServiceLocator.locate(DummyServiceProtocol.self)
    /// ```
    ///
    /// - Remark: Resolving an unregistered service will make the application crash
    /// - Parameter type: The type of the service
    /// - Returns: The instance of the service
    @discardableResult
    public static func locate<T>(_ type: T.Type) -> T {
        let key = ObjectIdentifier(type)
        guard let storedFactory = factories[key] else {
            fatalError("factory: \(type) is not registered")
        }
        
        let mode = storedFactory.0
        let factory = storedFactory.1
        
        switch mode {
        case .newInstance:
            guard let instance = factory() as? T else {
                fatalError("Is not the expected type: [\(type)]")
            }
            return instance
        default:
            guard let sharedInstance = self.sharedInstances[key] as? T else {
                guard let instance = factory() as? T else {
                    fatalError("Is not the expected type: [\(type)]")
                }
                self.sharedInstances[key] = instance
                return instance
            }
            return sharedInstance
        }
    }
    
    
    /// Unregister a service
    /// - Parameter type: the registered service to remove
    ///
    /// ```swift
    /// QuickServiceLocator.unregister(DummyServiceProtocol.self)
    /// ```
    ///
    /// The factory and the instance if present will be remove from the container
    public static func unregister<T>(_ type: T.Type) {
        let key = ObjectIdentifier(type)
        factories.removeValue(forKey: key)
        sharedInstances.removeValue(forKey: key)
    }
    
    /// Check if a service is registered
    /// - Parameter type: the registered service to check
    public static func isRegister<T>(_ type: T.Type) -> Bool {
        let key = ObjectIdentifier(type)
        return factories[key] != nil
    }
}
