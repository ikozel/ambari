name 'ambari'

version '0.3.0'

description 'Installs and configures Apache Ambari'
long_description IO.read File.expand_path '../README.md', __FILE__

license 'Apache 2.0'

maintainer 'Julien Pellet'
maintainer_email 'chef@julienpellet.com'

supports 'redhat', '>= 5.0'
supports 'centos', '>= 5.0'
supports 'amazon', '>= 5.0'
supports 'scientific', '>= 5.0'
supports 'suse', '>= 11.0'
supports 'ubuntu', '>= 12.0'

depends 'apt', '~> 2.7'
