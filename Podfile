# The use of implicit sources has been deprecated.
source 'https://github.com/CocoaPods/Specs.git'

# ignore all warnings from all pods
inhibit_all_warnings!
use_frameworks!
platform :ios, '9.0'

def commonDependencies()

    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SimulatorStatusMagic', '~> 1.8', :configurations => ['Debug']
    pod 'Alamofire', '~> 4.0'
    pod 'SwiftyJSON'
    pod 'KeychainAccess', '~> 3.0'
    pod 'MGSwipeTableCell'
    pod 'DTPhotoViewerController'
    pod 'RNCryptor', '~> 5.0'
    pod 'TTTAttributedLabel'
    pod 'MBProgressHUD', '~> 1.0.0'
    pod 'SlideMenuControllerSwift'
    pod 'InputMask'
    pod 'AKImageCropperView'
    pod 'KMPlaceholderTextView', '~> 1.3.0'
    pod 'NSStringMask', '~> 1.2.2'
    pod 'ReachabilitySwift'
    pod 'ExpandingMenu', '~> 0.4'

end

target 'MyMobileED' do
    commonDependencies()
end

target 'MyMobileED_Fabric' do
    commonDependencies()
end

def test_set
    pod 'OCMock', '~> 2.2.4'
end

target :Tests do
    test_set
end

target :ApplicationTests do
    test_set
end

target :LogicTests do
    test_set
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
