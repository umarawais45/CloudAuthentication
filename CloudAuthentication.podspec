#
# Be sure to run `pod lib lint CloudAuthentication.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CloudAuthentication'
  s.version          = '1.01'
  s.summary          = 'A framework that handles AWS and Firebase Authentication.'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  'It includes firebase anonymous login and aws federated sign-in.'
                       DESC

  s.homepage         = 'https://github.com/umarawais45/CloudAuthentication'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Umar Awais' => 'umar.awais45@gmail.com' }
  s.source           = { :git => 'https://github.com/umarawais45/CloudAuthentication.git', :tag => s.version.to_s }
#   s.social_media_url = 'https://www.linkedin.com/in/umarawais/<umarawais>'

  s.source_files = 'CloudAuthentication/Classes/**/*'
  
  
  
  s.platform = :ios, "13.0"
  s.ios.deployment_target = '13.0'
  
  s.dependency 'Firebase/Auth'
  s.dependency 'Amplify'
  s.dependency 'AmplifyPlugins/AWSCognitoAuthPlugin', '>= 0'
  s.dependency 'GoogleSignIn'
  
  # s.resource_bundles = {
  #   'CloudAuthentication' => ['CloudAuthentication/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
