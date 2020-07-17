//
//  CXCallObserver+Rx.swift
//  RxCallKit
//
//  Created by Pawel Rup on 24.01.2019.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import CallKit
import RxSwift
import RxCocoa

@available(iOS 10.0, macCatalyst 13, *)
extension CXCallObserver: HasDelegate {
	
	public typealias Delegate = CXCallObserverDelegate
	
	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}
}

@available(iOS 10.0, macCatalyst 13, *)
private class RxCXCallObserverDelegateProxy: DelegateProxy<CXCallObserver, CXCallObserverDelegate>, DelegateProxyType, CXCallObserverDelegate {
	
	public weak private (set) var observer: CXCallObserver?
	
	private var callChangedSubject = PublishSubject<CXCall>()
	
	var callChanged: Observable<CXCall>
	
	public init(observer: ParentObject) {
		self.observer = observer
		callChanged = callChangedSubject.asObservable()
		super.init(parentObject: observer, delegateProxy: RxCXCallObserverDelegateProxy.self)
	}
	
	static func registerKnownImplementations() {
		register { RxCXCallObserverDelegateProxy(observer: $0) }
	}
	
	func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
		callChangedSubject.onNext(call)
	}
}

@available(iOS 10.0, macCatalyst 13, *)
public extension Reactive where Base: CXCallObserver {
	
	private var delegate: DelegateProxy<CXCallObserver, CXCallObserverDelegate> {
		RxCXCallObserverDelegateProxy.proxy(for: base)
	}
	
	/// Called when a call is changed.
	var callChanged: Observable<CXCall> {
		(delegate as! RxCXCallObserverDelegateProxy).callChanged
	}
}
