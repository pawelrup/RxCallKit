#
# Be sure to run `pod lib lint RxCallKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxCallKit'
  s.version          = '0.1.1'
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

	s.swift_version = '5.0'
	
  s.source_files = 'RxCallKit/Classes/**/*'
	
	s.pod_target_xcconfig =  {
		'SWIFT_VERSION' => '5.0',
	}
	
	s.frameworks = 'CallKit'
	s.frameworks = 'AVFoundation'
	s.dependency 'RxSwift', '~> 4.5.0'
	s.dependency 'RxCocoa', '~> 4.5.0'
end
