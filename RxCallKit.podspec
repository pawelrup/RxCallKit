Pod::Spec.new do |s|
  s.name             = 'RxCallKit'
  s.version          = '0.2.0'
  s.summary          = 'Reactive extension for CallKit.'

  s.description      = <<-DESC
	RxCallKit is an RxSwift reactive extension for CallKit.
	Requires Xcode 10.2 with Swift 5.0.
                       DESC

  s.homepage         = 'https://github.com/pawelrup/RxCallKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paweł Rup' => 'pawelrup@lobocode.pl' }
  s.source           = { :git => 'https://github.com/pawelrup/RxCallKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

	s.swift_version = '5.3'

  s.source_files = 'Sources/RxCallKit/**/*'

	s.frameworks = 'CallKit'
	s.frameworks = 'AVFoundation'
	s.dependency 'RxSwift'
	s.dependency 'RxCocoa'
end
