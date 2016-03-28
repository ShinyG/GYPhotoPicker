Pod::Spec.new do |s|
  s.name         = 'GYPhotoPicker'
  s.version      = '1.0.0'
  s.summary  = 'A picker for photo when we need custom to select more than one'
  s.homepage     = 'https://github.com/ShinyG'
  s.license      = 'MIT'
  s.author       = {'ShinyG' => '80937676@qq.com'}
  s.source       = { :git => 'https://github.com/ShinyG/GYPhotoPicker.git', :tag => "#{s.version}" }
  # s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source_files = 'GYPhotoPicker/*.{h,m}'
  s.resource = 'GYPhotoPicker/GYPhotoPicker.bundle'
  s.requires_arc = true
end