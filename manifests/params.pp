# == Class: activemq::params
#
# Defaults for ActiveMQ
class activemq::params {

   $package_ensure = 'present'
   $package_name   = 'activemq'
   $configdir      = '/etc/activemq'
   $credentials    = "${configdir}/credentials.properties"
   $configfile     = "${configdir}/activemq.xml"
   # 
   $amquser        = 'activemq'
   $amqgroup       = 'activemq'
   $amqbrokername  = $::fqdn

   # SystemUsage variables for activemq.
   $amqmemory      = '20 mb'
   $amqstore       = '1 gb'
   $amqtemp        = '100 mb'

   #tanuki wrapper variables.
   $configwrapper          = '/etc/activemq/activemq-wrapper.conf'
   $amqrestart             = true
   $dedicatedTaskRunner    = true
   # This is bit horrible, relies on what ever we are given in the package.
   $dedicatedTaskRunnerKey = 'wrapper.java.additional.4'
   $max_memory             = '512'
   
   # Set up a keystore?
   $keystore               = false
   $ca                     = '/var/lib/puppet/ssl/ca/ca_crt.pem'
   $cert                   = "/var/lib/puppet/ssl/certs/${::fqdn}.pem"
   $key                    = "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
   $keystore_pass          = 'setmeifyoucare'

   # Files and number of process for activemq user
   $amqfilelimit           = '4096'
   $amqproclimit           = '1024'

}
