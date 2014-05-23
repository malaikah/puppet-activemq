# == Class: activemq
#
# Installs, configures and starts ActiveMQ service.
#
# === Parameters
#
# [*package_ensure*]
#   ensure parameter for activemq package, defaults to present.
#
# [*package_name*]
#   Name of the package, defaults to activemq.
#
# [*configdir*]
#   Activemq configuration directory, defaults to /etc/activemq
#
# [*amqmemory*]
#   Parameter for <memoryUsage limit="20 mb"/> element, defaults to '20 mb'.
#
# [*amqstore*]
#   Parameter for <storeUsage  limit="1 gb"/>, defaults to '1 gb'.
#
# [*amqtemp*]
#   Parameter for <tempUsage   limit="100 mb"/>, defaults to '100 mb'.
#
# [*configwrapper*]
#   Location of tanuki wrapper configuration, default to 
#   /etc/activemq/activemq-wrapper.conf
#
# [*dedicatedTaskRunner*]
#   A boolean defaulting to true, it sets up
#   wrapper.java.additional.4=-Dorg.apache.activemq.UseDedicatedTaskRunner=false
#   with true or false.
#
# [*dedicatedTaskRunnerKey*]
#   The key in the activemq-wrapper.conf to use for the setting of
#   -Dorg.apache.activemq.UseDedicatedTaskRunner, defaults
#   to 'wrapper.java.additional.4'
#
# [*maxMemory*]
#   Sets the wrapper.java.maxmemory value in activemq-wrapper.conf file
#   to set up max heat size for the java machine. Defaults to '512'. Units
#   are MBs.
#
# [*keystore*]
#   Should a java keystore be set up and used in the activemq.xml file.
#   A boolean and defaults to false.
#
# [*keystorepass*]
#   The password to use for newly created keystore.
#
# [*ca*]
#   If a keystore is used the location of certificate authority .pem
#   file. Defaults to '/var/lib/puppet/ssl/ca/ca_crt.pem'
#
# [*cert*]
#   If a keystore is used the location of the service's  publiccertificate .pem
#   file. Defaults to '/var/lib/puppet/ssl/certs/${::fqdn}.pem'
#
# [*key*]
#   If a keystore is used the location of the service's private key .pem
#   file. Defaults to '/var/lib/puppet/ssl/private_keys/${::fqdn}.pem'.
#
# [*amqrestart*]
#   If the activemq.xml file is changed should the activemq service
#   be changed. This boolean is default true. Future versions of
#   of activemq should support dynamic reloading of configuration.
#
# [*amquser*]
#   User that runs ActiveMQ, defaults to 'activemq'.
#
# [*amqgroup*]
#   Group that runs ActiveMQ, defaults to 'activemq'.
#
# [*amqfilelimit*]
#   Sets a soft and hard limit for 'nofile' for the ActiveMQ user
#   in /etc/security/limits.conf.
#
# [*amqproclimit*]
#   Sets a soft and hard limit for 'nproc' for the ActiveMQ user
#   in /etc/security/limits.conf.
# 
# [*amqbrokername*]
#   The name of broker , defaults to $::fqdn.
#
# === Examples
#
#   class{ 'activemq':
#      amqmemory  => '2 gb',
#      amqstore   => '10 gb',
#      amqtemp    => '1 gb',
#      max_memory => '36195',   # 36195
#      dedicatedTaskRunner => false,
#      keystore            => true,
#      ca                  => '/etc/pki/tls/certs/MYCA-bundle.pem',
#      amqrestart          => true,
#      amqfilelimit        => '105000',
#      amqproclimit        => '10240'
#
#   }
#
# === Copyright
#
# Steve Traylen, CERN, 2014, steve@traylen@cern.ch
#
class activemq  (
  $package_ensure         = $activemq::params::package_ensure,
  $package_name           = $activemq::params::package_name,
  $configdir              = $activemq::params::configdir,
  $credentials            = $activemq::params::credentials,
  $configfile             = $activemq::params::configfile,
  $amqmemory              = $activemq::params::amqmemory,
  $amqstore               = $activemq::params::amqstore,
  $amqtemp                = $activemq::params::amqtemp,
  $configwrapper          = $activemq::params::configwrapper,
  $dedicatedTaskRunner    = $activemq::params::dedicatedTaskRunner,
  $dedicatedTaskRunnerKey = $activemq::params::dedicatedTaskRunnerKey,
  $max_memory             = $activemq::params::max_memory,
  $keystore               = $activemq::params::keystore,
  $keystore_pass          = $activemq::params::keystore_pass,
  $ca                     = $activemq::params::ca,
  $key                    = $activemq::params::key,
  $cert                   = $activemq::params::cert,
  $amqrestart             = $activemq::params::amqrestart,
  $amquser                = $activemq::params::amquser,
  $amqgroup               = $activemq::params::amqgroup,
  $amqfilelimit           = $activemq::params::amqfilelimit,
  $amqproclimit           = $activemq::params::amqproclimit,
  $amqbrokername          = $activemq::params::amqbrokername

) inherits activemq::params {

    validate_string($amqfilelimit)
    validate_string($amqproclimit)
    validate_string($amqbrokername)
    validate_string($package_version)
    validate_string($package_name)
    validate_string($amqmemory)
    validate_string($amqstore)
    validate_string($amqtemp)
    validate_string($configdir)
    validate_string($configwrapper)
    validate_bool($dedicatedTaskRunner)
    validate_string($dedicatedTaskRunnerKey)
    validate_string($amquser)
    validate_string($amqgroup)
    validate_bool($keystore)
    if $keystore {
      validate_string($keystore_pass)
      validate_string($ca)
      validate_string($key)
      validate_string($cert)
    }

    anchor {'activemq::begin': } ->
    class{'activemq::install': } ->
    class{'activemq::config': } ->
    class{'activemq::service': } ->
    anchor {'activemq::end': }

}

