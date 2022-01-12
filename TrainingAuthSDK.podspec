Pod::Spec.new do |spec|
    spec.name                  = "TrainingAuthSDK"
    spec.version               = "0.1.0"
    spec.summary               = ""
    spec.homepage              = "https://github.com/nnsnodnb/MultipleImageView"
    spec.swift_version         = "5.0"
    spec.license               = { :type => "MIT", :file => "LICENSE" }
    spec.author                = { "nnsnodnb" => "nnsnodnb@gmail.com" }
    spec.social_media_url      = "https://twitter.com/nnsnodnb"
    spec.platform              = :ios
    spec.platform              = :ios, "9.0"
    spec.ios.deployment_target = "9.0"
    spec.ios.framework         = "UIKit"
    spec.source                = { :git => "https://github.com/nnsnodnb/#{spec.name}.git", :tag => "#{spec.version}" }
    spec.source_files          = "Sources/#{spec.name}/*.swift"

    spec.dependency "APIKit", "~> 5.3.0"
    spec.dependency "KeychainAccess", "~> 4.2.2"
  end
