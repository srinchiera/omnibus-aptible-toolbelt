require_relative './../../util/version.rb'
require_relative './../../util/clean_software.rb'

name 'aptible-toolbelt'
maintainer 'Thomas Orozco <thomas@aptible.com>'
homepage 'https://www.aptible.com'
license 'MIT'
license_file 'LICENSE.md'

install_dir "#{default_root}/#{name}"

build_version do
  source :git, from_dependency: 'aptible-cli'
  output_format :semver_with_platform
end

build_iteration 1

# Creates required build directories
dependency 'preparation'

override :zlib, source: {
  url: 'http://pilotfiber.dl.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.gz'
}

# aptible-cli dependencies/components
override :ruby, version: '2.2.4'
dependency 'aptible-cli'

# Version manifest file
dependency 'version-manifest'

exclude '**/.git'
exclude '**/bundler/git'

package :pkg do
  identifier 'com.aptible.toolbelt'
  signing_identity 'Developer ID Installer: Chas Ballew (79J6PXK4K8)'
end
