Pod::Spec.new do |s|
  s.name     = 'AFNetworking'
  s.version  = '3.1.0'
  s.license  = 'MIT'
  s.summary  = 'A delightful iOS and OS X networking framework.'
  s.homepage = 'https://github.com/AFNetworking/AFNetworking'
  s.social_media_url = 'https://twitter.com/AFNetworking'
  s.authors  = { 'Mattt Thompson' => 'm@mattt.me' }
  s.source   = { :git => 'https://github.com/AFNetworking/AFNetworking.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  
  s.ios.deployment_target = '7.0'
  s.vendored_frameworks = 'AFNetworking.framework'
end
