//
//  CXProvider+Rx.swift
//  RxCallKit
//
//  Created by Pawel Rup on 24.01.2019.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import CallKit
import AVFoundation
import RxSwift
import RxCocoa

@available(iOS 10.0, macCatalyst 13, *)
extension CXProvider: HasDelegate {
	
	public typealias Delegate = CXProviderDelegate
	
	public var delegate: Delegate? {
		get {
			value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}
}

@available(iOS 10.0, macCatalyst 13, *)
private class RxCXProviderDelegateProxy: DelegateProxy<CXProvider, CXProviderDelegate>, DelegateProxyType, CXProviderDelegate {
	
	public weak private (set) var provider: CXProvider?
	
	private var providerDidResetSubject = PublishSubject<Void>()
	private var performStartCallSubject = PublishSubject<CXStartCallAction>()
	private var performAnswerCallSubject = PublishSubject<CXAnswerCallAction>()
	private var performEndCallSubject = PublishSubject<CXEndCallAction>()
	private var performSetHeldCallSubject = PublishSubject<CXSetHeldCallAction>()
	private var performSetMutedCallSubject = PublishSubject<CXSetMutedCallAction>()
	private var performSetGroupCallSubject = PublishSubject<CXSetGroupCallAction>()
	private var performPlayDTMFCallSubject = PublishSubject<CXPlayDTMFCallAction>()
	
	var providerDidReset: Observable<Void>
	var performStartCall: Observable<CXStartCallAction>
	var performAnswerCall: Observable<CXAnswerCallAction>
	var performEndCall: Observable<CXEndCallAction>
	var performSetHeldCall: Observable<CXSetHeldCallAction>
	var performSetMutedCall: Observable<CXSetMutedCallAction>
	var performSetGroupCall: Observable<CXSetGroupCallAction>
	var performPlayDTMFCall: Observable<CXPlayDTMFCallAction>
	
	public init(provider: ParentObject) {
		self.provider = provider
		providerDidReset = providerDidResetSubject.asObservable()
		performStartCall = performStartCallSubject.asObservable()
		performAnswerCall = performAnswerCallSubject.asObservable()
		performEndCall = performEndCallSubject.asObservable()
		performSetHeldCall = performSetHeldCallSubject.asObservable()
		performSetMutedCall = performSetMutedCallSubject.asObservable()
		performSetGroupCall = performSetGroupCallSubject.asObservable()
		performPlayDTMFCall = performPlayDTMFCallSubject.asObservable()
		super.init(parentObject: provider, delegateProxy: RxCXProviderDelegateProxy.self)
	}
	
	static func registerKnownImplementations() {
		register { RxCXProviderDelegateProxy(provider: $0) }
	}
	
	func providerDidReset(_ provider: CXProvider) {
		providerDidResetSubject.onNext(())
	}
	
	func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
		performStartCallSubject.onNext(action)
	}
	
	func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
		performAnswerCallSubject.onNext(action)
	}
	
	func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
		performEndCallSubject.onNext(action)
	}
	
	func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
		performSetHeldCallSubject.onNext(action)
	}
	
	func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
		performSetMutedCallSubject.onNext(action)
	}
	
	func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
		performSetGroupCallSubject.onNext(action)
	}
	
	func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
		performPlayDTMFCallSubject.onNext(action)
	}
}

@available(iOS 10.0, macCatalyst 13, *)
public extension Reactive where Base: CXProvider {
	
	private var delegate: DelegateProxy<CXProvider, CXProviderDelegate> {
		RxCXProviderDelegateProxy.proxy(for: base)
	}
	
	/// Reports a new incoming call with the specified unique identifier to the provider.
	///
	/// - Parameters:
	///   - UUID: The unique identifier of the call.
	///   - update: The information for the call.
	func reportNewIncomingCall(with UUID: UUID, update: CXCallUpdate) -> Completable {
		Completable.create { completable in
			base.reportNewIncomingCall(with: UUID, update: update) { error in
				if let error = error {
					completable(.error(error))
				} else {
					completable(.completed)
				}
			}
			return Disposables.create()
		}
	}
	/// Called when the provider has been reset. Delegates must respond to this callback by cleaning up all internal call state (disconnecting communication channels, releasing network resources, etc.). This callback can be treated as a request to end all calls without the need to respond to any actions
	var didReset: Observable<Void> {
		(delegate as! RxCXProviderDelegateProxy).providerDidReset
	}
	
	/// Called when the provider has been fully created and is ready to send actions and receive updates
	var didBegin: Observable<Void> {
		delegate
			.methodInvoked(#selector(CXProviderDelegate.providerDidBegin(_:)))
			.map { _ in () }
	}
	
	var executeTransaction: Observable<CXTransaction> {
		delegate
			.methodInvoked(#selector(CXProviderDelegate.provider(_:execute:)))
			.compactMap { $0[1] as? CXTransaction }
	}
	
	/// Called when the provider performs the specified start call action.
	var performStartCall: Observable<CXStartCallAction> {
		(delegate as! RxCXProviderDelegateProxy).performStartCall
	}
	
	/// Called when the provider performs the specified answer call action.
	var performAnswerCall: Observable<CXAnswerCallAction> {
		(delegate as! RxCXProviderDelegateProxy).performAnswerCall
	}
	
	/// Called when the provider performs the specified end call action.
	var performEndCall: Observable<CXEndCallAction> {
		(delegate as! RxCXProviderDelegateProxy).performEndCall
	}
	
	/// Called when the provider performs the specified set held call action.
	var performSetHeldCall: Observable<CXSetHeldCallAction> {
		(delegate as! RxCXProviderDelegateProxy).performSetHeldCall
	}
	
	/// Called when the provider performs the specified set muted call action.
	var performSetMutedCall: Observable<CXSetMutedCallAction> {
		(delegate as! RxCXProviderDelegateProxy).performSetMutedCall
	}
	
	/// Called when the provider performs the specified set group call action.
	var performSetGroupCall: Observable<CXSetGroupCallAction> {
		(delegate as! RxCXProviderDelegateProxy).performSetGroupCall
	}
	
	/// Called when the provider performs the specified play DTMF (dual tone multifrequency) call action.
	var performPlayDTMFCall: Observable<CXPlayDTMFCallAction> {
		(delegate as! RxCXProviderDelegateProxy).performPlayDTMFCall
	}
	
	/// Called when the provider performs the specified action times out.
	var timedOutPerforming: Observable<CXAction> {
		delegate
			.methodInvoked(#selector(CXProviderDelegate.provider(_:timedOutPerforming:)))
			.compactMap { $0[1] as? CXAction }
	}
	
	/// Called when the provider’s audio session is activated.
	var didActivate: Observable<AVAudioSession> {
		delegate
			.methodInvoked(#selector(CXProviderDelegate.provider(_:didActivate:)))
			.compactMap { $0[1] as? AVAudioSession }
	}
	
	/// Called when the provider’s audio session is deactivated.
	var didDeactivate: Observable<AVAudioSession> {
		delegate
			.methodInvoked(#selector(CXProviderDelegate.provider(_:didDeactivate:)))
			.compactMap { $0[1] as? AVAudioSession }
	}
}
