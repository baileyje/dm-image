Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name = 'DMImage'
  spec.version = '0.0.1'
  spec.summary = 'A set of image related utilities including an image cache and pre-decoder.'
  spec.description = <<-DESC

  DESC
  spec.homepage = 'http://devmode.com/projects/dm-image'
  spec.documentation_url = 'http://devmode.com/projects/dm-image'

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.license = { :type => 'MIT', :file =>  'LICENSE-MIT' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.authors = {
    'John E. Bailey' => 'john@devmode.com',
    'Sean M. Duncan' => 'sean@devmode.com'
  }
  spec.social_media_url = 'http://twitter.com/DevModeInc'


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.platform = :ios, 6.0


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source = { :git => 'https://github.com/devmode/dm-image.git', :tag => spec.version }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  spec.public_header_files = 'Classes/**/*.h'


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # None


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.dependency 'DMFoundation', '~> 0.0.1'
  spec.dependency 'DMRequest',  '~> 0.1.2'


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.requires_arc = true

end
