//
//  QuickSL.swift
//  
//
//  Created by François Dabonot on 18/08/2024.
//

import Foundation

/// When no parameter : **Resolve** a service which must be compliant with **Instance type**.
/// When register parameter used : **Register** a service with an instance from a factory
/// which must be compliant with the targeted **Instance type**
@propertyWrapper
public struct QuickSL<Instance> {
    
    /// **Resolve** a service which must be compliant with **Instance type**
    public init() {}
        
    /// **Register** a service with an instance from a factory which must
    /// be compliant with the targeted **Instance type**
    ///
    /// You can change the way the service is loaded by changing the *mode* : by default **lazySharedInstance**
    public init(register: @autoclosure @escaping () -> Instance,
         mode: LocatingMode = .lazySharedInstance) {
        QuickServiceLocator.register(Instance.self, mode: mode, register() )
    }
    
    public var wrappedValue: Instance {
        QuickServiceLocator.locate()
    }
    
    /// Resolve service from the return type
    /// - Remark: Resolving an unregistered service will make the application crash
    public static func resolve() -> Instance {
        QuickServiceLocator.locate()
    }
}
