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

@available(iOS 10.0, macCatalyst 13, *)
public extension Reactive where Base: CXCallController {
	
	func request(_ transaction: CXTransaction) -> Completable {
		Completable.create { completable in
			base.request(transaction) { error in
				if let error = error {
					completable(.error(error))
				} else {
					completable(.completed)
				}
			}
			return Disposables.create()
		}
	}
	
	@available(iOS 11.0, macCatalyst 13, *)
	func requestTransaction(with actions: [CXAction]) -> Completable {
		Completable.create { completable in
			base.requestTransaction(with: actions) { error in
				if let error = error {
					completable(.error(error))
				} else {
					completable(.completed)
				}
			}
			return Disposables.create()
		}
	}
	
	@available(iOS 11.0, macCatalyst 13, *)
	func requestTransaction(with action: CXAction) -> Completable {
		Completable.create { completable in
			base.requestTransaction(with: action) { error in
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
