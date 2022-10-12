Pod::Spec.new do |spec|
    spec.name                  = "TrainingAuthSDK"
    spec.version               = "0.1.0"
    spec.summary               = "https://github.com/nnsnodnb/training_webapi's iOS Auth SDK."
    spec.homepage              = "https://github.com/nnsnodnb/MultipleImageView"
    spec.swift_version         = "5.0"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "nnsnodnb" => "nnsnodnb@gmail.com" }
    spec.social_media_url      = "https://twitter.com/nnsnodnb"
    spec.platform              = :ios, "10.0"
    spec.ios.deployment_target = "10.0"
    spec.ios.framework         = "UIKit"
    spec.source                = { :git => "https://github.com/nnsnodnb/#{spec.name}.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/**/*.{swift,h,m}"

    spec.dependency "APIKit", "~> 5.0.0"
    spec.dependency "KeychainAccess", "~> 4.0.0"
    spec.dependency "JWTDecode", "~> 3.0.0"
  end
