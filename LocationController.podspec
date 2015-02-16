Pod::Spec.new do |s|
  s.name         = "LocationController"
  s.version      = "0.0.1"
  s.summary      = "LocationController is a nifty tool for getting the location"

  s.description  = <<-DESC
    LocationController is a great tool that will give you a lot more
    flexibility and lets you focus on other stuff than creating controllers.    
  DESC

  s.homepage     = "http://github.com/westerlund/LocationController"
  s.license      = "WTFPL"
  s.author             = { "Simon Westerlund" => "s@simonwesterlund.se" }
  s.social_media_url   = "http://twitter.com/wesslansimon"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/westerlund/LocationController", :tag => "0.0.1" }

  s.source_files  = "Source/*.swift"
  s.framework  = "CoreLocation"
  s.requires_arc = true
end
