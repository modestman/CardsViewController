Pod::Spec.new do |s|
  s.name             = 'CardsViewController'
  s.version          = '1.3.0'
  s.summary          = 'CardsViewController is an implementation of collection swipeable cards.'
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
