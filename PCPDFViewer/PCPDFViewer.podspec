Pod::Spec.new do |s|

  s.name         = "PCPDFViewer"
  s.version      = "1.0.0"
  s.summary      = "A PDF Viewer library with Page Curl"

  s.description  = <<-DESC
                    PCPDFViewer is a library to show PDF in simple and easy way with Page curl effect. User can zoom in and zoom out each page
                   DESC

  s.homepage     = "https://github.com/shahid-nasrullah-globit/PCPDFViewer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Shahid Nasrullah" => "shn@quantumcph.com" }
  s.ios.deployment_target = '9.0'

  s.source       = { :git => "https://github.com/shahid-nasrullah-globit/PCPDFViewer.git", :tag => "#{s.version}" }
  s.source_files  = "*.{swift}"
  s.exclude_files = "Classes/Exclude"
  s.resources = ["Resources/**/*.storyboard"]

end
