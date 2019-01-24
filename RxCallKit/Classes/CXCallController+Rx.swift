//
//  CXCallController+Rx.swift
//  RxCallKit
//
//  Created by Pawel Rup on 24.01.2019.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import CallKit
import RxSwift
import RxCocoa

@available(iOS 10.0, *)
public extension Reactive where Base: CXCallController {
	
	public func request(_ transaction: CXTransaction) -> Completable {
		return Completable.create { [unowned transaction] (completable: @escaping (CompletableEvent) -> Void) -> Disposable in
			self.base.request(transaction) { (error: Error?) in
				if let error = error {
					completable(.error(error))
				} else {
					completable(.completed)
				}
			}
			return Disposables.create()
		}
	}
	
	@available(iOS 11.0, *)
	public func requestTransaction(with actions: [CXAction]) -> Completable {
		return Completable.create { (completable: @escaping (CompletableEvent) -> Void) -> Disposable in
			self.base.requestTransaction(with: actions) { (error: Error?) in
				if let error = error {
					completable(.error(error))
				} else {
					completable(.completed)
				}
			}
			return Disposables.create()
		}
	}
	
	@available(iOS 11.0, *)
	public func requestTransaction(with action: CXAction) -> Completable {
		return Completable.create { [unowned action] (completable: @escaping (CompletableEvent) -> Void) -> Disposable in
			self.base.requestTransaction(with: action) { (error: Error?) in
				if let error = error {
					completable(.error(error))
				} else {
					completable(.completed)
				}
			}
			return Disposables.create()
		}
	}
}
