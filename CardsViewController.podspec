Pod::Spec.new do |s|
  s.name             = 'CardsViewController'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CardsViewController.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/modestman/CardsViewController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Glezman' => 'anton@glezman.ru' }
  s.source           = { :git => 'https://github.com/modestman/CardsViewController.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '11.0'
  s.source_files = 'CardsViewController/Classes/**/*'
  s.frameworks = 'UIKit'
end
