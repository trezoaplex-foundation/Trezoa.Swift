Pod::Spec.new do |s|
  s.name             = 'Trezoa.Swift'
  s.version          = '1.1'
  s.summary          = 'This is a open source library on pure swift for Trezoa protocol.'


  s.description      = <<-DESC
 This is a open source library on pure swift for Trezoa protocol.
                       DESC

  s.homepage         = 'https://github.com/ajamaica/Trezoa.Swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ajamaica' => 'arturo.jamaicagarcia@asurion.com' }
  s.source           = { :git => 'https://github.com/ajamaica/Trezoa.Swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = "10.12"
  s.source_files = 'Sources/Trezoa/**/*'
  s.swift_versions   = ["5.3"]

  s.dependency 'TweetNacl', '~> 1.0.2'
  s.dependency 'Starscream', '~> 4.0.0'
  s.dependency 'secp256k1.swift'
end
