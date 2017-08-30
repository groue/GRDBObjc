Pod::Spec.new do |s|
  s.name         = 'GRDBObjc'
  s.version      = '0.1'
  
  s.license      = { :type => 'MIT' }
  s.homepage     = 'https://github.com/groue/GRDBObjc'
  s.authors      = { 'Gwendal Roué' => 'gr@pierlis.com' }
  s.summary      = 'Objective-C bindings for GRDB.'
  s.source       = { :git => 'https://github.com/groue/GRDBObjc.git', :tag => "v#{s.version}" }
  s.module_name = 'GRDBObjc'
  
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  
  s.source_files = 'Sources/*'
  s.dependency "GRDB.swift" # , "~> 2.0"
  s.framework = 'Foundation'
  s.library = 'sqlite3'
end
