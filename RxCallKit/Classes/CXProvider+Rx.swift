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

extension CXProvider: HasDelegate {
	
	public typealias Delegate = CXProviderDelegate
	
	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}
}

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
		self.register { RxCXProviderDelegateProxy(provider: $0) }
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

public extension Reactive where Base: CXProvider {
	
	private var delegate: DelegateProxy<CXProvider, CXProviderDelegate> {
		return RxCXProviderDelegateProxy.proxy(for: base)
	}
	
	/// Reports a new incoming call with the specified unique identifier to the provider.
	///
	/// - Parameters:
	///   - UUID: The unique identifier of the call.
	///   - update: The information for the call.
	func reportNewIncomingCall(with UUID: UUID, update: CXCallUpdate) -> Completable {
		return Completable.create { [unowned update] (completable: @escaping (CompletableEvent) -> Void) -> Disposable in
			self.base.reportNewIncomingCall(with: UUID, update: update) { (error: Error?) in
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
	@available(iOS 10.0, *)
	var didReset: Observable<Void> {
		return (delegate as! RxCXProviderDelegateProxy).providerDidReset
	}
	
	/// Called when the provider has been fully created and is ready to send actions and receive updates
	@available(iOS 10.0, *)
	var didBegin: Observable<Void> {
		return delegate.methodInvoked(#selector(CXProviderDelegate.providerDidBegin(_:)))
			.map { _ in () }
	}
	
	/// Called when the provider performs the specified start call action.
	@available(iOS 10.0, *)
	var performStartCall: Observable<CXStartCallAction> {
		return (delegate as! RxCXProviderDelegateProxy).performStartCall
	}
	
	/// Called when the provider performs the specified answer call action.
	@available(iOS 10.0, *)
	var performAnswerCall: Observable<CXAnswerCallAction> {
		return (delegate as! RxCXProviderDelegateProxy).performAnswerCall
	}
	
	/// Called when the provider performs the specified end call action.
	@available(iOS 10.0, *)
	var performEndCall: Observable<CXEndCallAction> {
		return (delegate as! RxCXProviderDelegateProxy).performEndCall
	}
	
	/// Called when the provider performs the specified set held call action.
	@available(iOS 10.0, *)
	var performSetHeldCall: Observable<CXSetHeldCallAction> {
		return (delegate as! RxCXProviderDelegateProxy).performSetHeldCall
	}
	
	/// Called when the provider performs the specified set muted call action.
	@available(iOS 10.0, *)
	var performSetMutedCall: Observable<CXSetMutedCallAction> {
		return (delegate as! RxCXProviderDelegateProxy).performSetMutedCall
	}
	
	/// Called when the provider performs the specified set group call action.
	@available(iOS 10.0, *)
	var performSetGroupCall: Observable<CXSetGroupCallAction> {
		return (delegate as! RxCXProviderDelegateProxy).performSetGroupCall
	}
	
	/// Called when the provider performs the specified play DTMF (dual tone multifrequency) call action.
	@available(iOS 10.0, *)
	var performPlayDTMFCall: Observable<CXPlayDTMFCallAction> {
		return (delegate as! RxCXProviderDelegateProxy).performPlayDTMFCall
	}
	
	/// Called when the provider performs the specified action times out.
	@available(iOS 10.0, *)
	var timedOutPerforming: Observable<CXAction> {
		return delegate.methodInvoked(#selector(CXProviderDelegate.provider(_:timedOutPerforming:)))
			.map { $0[1] as! CXAction }
	}
	
	/// Called when the provider’s audio session is activated.
	@available(iOS 10.0, *)
	var didActivate: Observable<AVAudioSession> {
		return delegate.methodInvoked(#selector(CXProviderDelegate.provider(_:didActivate:)))
			.map { $0[1] as! AVAudioSession }
	}
	
	/// Called when the provider’s audio session is deactivated.
	@available(iOS 10.0, *)
	var didDeactivate: Observable<AVAudioSession> {
		return delegate.methodInvoked(#selector(CXProviderDelegate.provider(_:didDeactivate:)))
			.map { $0[1] as! AVAudioSession }
	}
}
