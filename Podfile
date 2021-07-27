source 'https://github.com/CocoaPods/Specs.git'

def shared_dependencies
  pod 'CocoaAsyncSocket', '7.6.4'
end

target 'HappyDNS_iOS' do
  platform :ios, "6.0"
  # Pods for Doh
  shared_dependencies
end

target "HappyDNS_Mac" do
  platform :osx, "10.8"
  shared_dependencies
end

target "HappyDNS_iOSTests" do
  platform :ios, "6.0"
  pod 'AGAsyncTestHelper/Shorthand'
end

target "HappyDNS_MacTests" do
  platform :osx, "10.8"
  pod 'AGAsyncTestHelper/Shorthand'
end
