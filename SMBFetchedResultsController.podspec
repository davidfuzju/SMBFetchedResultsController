#
# Be sure to run `pod lib lint SMBFetchedResultsController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SMBFetchedResultsController"
  s.version          = "0.1.1"
  s.summary          = "it is a simple implemtation with NSFetchedRestulsController style based on To-Many Relationship Compliance"
  s.description      = <<-DESC
                        SMBFetchedResultsController is inspired by Cocoa's NSFetchedResultsController style and Cocoa's KVO To-Many Relationship Compliance to support insert, delete, move, replace operation to NSOrderedSet data struct'
                        DESC
  s.homepage         = "https://github.com/SuperMarioBean/SMBFetchedResultsController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "David Fu" => "david.fu.zju.dev@gmail.com" }
  s.source           = { :git => "https://github.com/SuperMarioBean/SMBFetchedResultsController.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SMBFetchedResultsController' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
