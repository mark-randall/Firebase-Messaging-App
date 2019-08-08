source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'

use_frameworks!
inhibit_all_warnings!

def commonPods
    
    #Crashlytics
    pod 'Fabric'
    pod 'Crashlytics'

    #Firebase
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Firebase/Performance'
    pod 'Firebase/Messaging'
    pod 'FirebaseUI/Auth'
    pod 'FirebaseUI/Google'
    pod 'FirebaseUI/Email'
    
    #Linting swift syntax
    pod 'SwiftLint'
end

target 'MessagingPOC' do
    
    commonPods
    
    target 'MessagingPOCTests' do
        inherit! :search_paths
    end
end

#updates Acknowledgements.plist
#post_install do | installer |
#    require 'fileutils'
#    FileUtils.cp_r('Pods/Target Support Files/Pods-MessagingPOC/Pods-MessagingPOC-Acknowledgements.plist', 'MessagingPOC/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
# FileUtils.cp_r('Pods/Target Support Files/Pods-MessagingPOC/Pods-MessagingPOC-Acknowledgements.plist', 'MessagingPOC/Resources/Acknowledgements.plist', :remove_destination => true)
#end
