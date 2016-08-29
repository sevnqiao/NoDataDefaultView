#NoDataDefaultView.podspec
Pod::Spec.new do |s|
s.name         = "NoDataDefaultView"
s.version      = "0.0.4"
s.summary      = "a light weight and easy to use NoDataDefaultView"
s.homepage     = "https://github.com/sevnqiao/NoDataDefaultView"
s.license      = 'MIT'
s.author       = { "sevn_Xiong" => "1020203007@qq.com" }
s.source       = { :git => "https://github.com/sevnqiao/NoDataDefaultView.git", :tag => s.version}
s.source_files  = 'SingleTableView/NoDataDefaultView/*.{h,m}'
s.requires_arc = true
end