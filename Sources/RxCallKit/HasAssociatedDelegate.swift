//
//  AssociatedDelegate.swift
//  
//
//  Created by ipagong on 2020/07/23.
//

import Foundation
import ObjectiveC
import RxSwift
import RxCocoa

public protocol HasAssociatedDelegate: HasDelegate {
    static var associatedDelegateKey: String { get }
}

extension HasAssociatedDelegate {
        func getAssociatedDelegate(forKey key: UnsafeRawPointer) -> Delegate? {
        return objc_getAssociatedObject(self, key) as? Delegate
    }
    
    func setAssociatedDelegate(_ object: Delegate?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_ASSIGN)
    }
}
