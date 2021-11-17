Pod::Spec.new do |s|
  s.name          = "InputCharacterCustomView"
  s.version       = "0.0.1"
  s.summary       = "iOS SDK use display input custom"
  s.description   = "Using for iOS custom UI"
  s.homepage      = "https://github.com/dung00275/"
  s.license       = "MIT"
  s.author        = "DungVu"
  s.source        = {
    :git => "https://github.com/dung00275/InputCharacterCustomView.git"
  }
  s.platform      = :ios, "10.0"
  s.source_files        = "InputCharacterCustomView/*.{h,m,swift}"
  s.public_header_files = "InputCharacterCustomView/*.h"
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
end
