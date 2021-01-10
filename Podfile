platform :ios, '12.0'

target 'Liste' do
  use_frameworks!
  inhibit_all_warnings!

  pod 'Hero'
  pod 'SwiftLint'
  pod 'RNCryptor'
  pod 'Firebase/Auth'
  pod 'SwiftConfettiView'
  pod 'Firebase/Firestore'  
  pod 'FirebaseFirestoreSwift'
  pod 'MSCircularSlider'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new('9.0') > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
