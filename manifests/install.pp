# == Class: activemq::install
# Installs activemq.
class activemq::install inherits activemq {

  package{'activemq':
    ensure => $::activemq::package_ensure,
    name   => $::activemq::package_name
  }

}
