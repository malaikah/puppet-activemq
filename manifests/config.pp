# == Class: activemq::config
# Does the generic configuration of ActiveMQ
#
# === Copyright
# Steve Traylen, CERN, 2014, steve.traylen@cern.ch
#
class activemq::config inherits activemq {
  
    datacat{$credentials:
       template => "activemq/credentials.properties.erb",
       owner => 'root',
       group => 'root',
       mode  => '0644'
    }

    # activemq.xml
    datacat{$configfile:
       template => 'activemq/activemq.xml.erb',
       owner    => 'root',
       group    => 'root',
       mode     => '0644'
    }

    datacat_fragment{'insert_single_values':
        target => $configfile,
        data   => {
                     single =>
                      { 'memory' => $amqmemory,
                        'store'  => $amqstore,
                        'temp'   => $amqtemp,
                        'brokername' => $amqbrokername
                      }
                  }
    }
    # Tanuki wrapper
    $value  = $dedicatedTaskRunner ? {
        true  => 'true',
        false => 'false'
    }
    augeas{'activemq_tanuki_wrapper':
      changes => ["set wrapper.java.maxmemory ${max_memory}",
                  "set ${dedicatedTaskRunnerKey} -Dorg.apache.activemq.UseDedicatedTaskRunner=${value}"],
      incl    => $configwrapper,
      lens    => 'Properties.lns',
      notify  => Service['activemq'],
    }

    if $keystore {
       file{"${configdir}/ssl_credentials":
          ensure => directory,
          mode   => '0700',
       }
       file{"${configdir}/ssl_credentials/activemq_certificate.pem":
          ensure => file,
          mode   => '0640',
          source => $cert,
       }
       file{"${configdir}/ssl_credentials/activemq_private.pem":
          ensure => file,
          mode   => '0600',
          source => $key,
       }
       file{"${configdir}/ssl_credentials/ca.pem":
          ensure => file,
          mode   => '0600',
          source => $ca,
       }
       java_ks { 'activemq_cert:keystore':
        ensure       => latest,
        certificate  => "${configdir}/ssl_credentials/activemq_certificate.pem",
        private_key  => "${configdir}/ssl_credentials/activemq_private.pem",
        target       => "${configdir}/keystore.jks",
        password     =>  $keystore_pass,
        require      => [
          File["${configdir}/ssl_credentials/activemq_private.pem"],
          File["${configdir}/ssl_credentials/activemq_certificate.pem"]
        ],
      }
      file{"${configdir}/keystore.jks":
          ensure  => file,
          replace => false,
          owner   => $amquser,
          group   => $amqgroup,
          mode    => '0600',
          require => Java_ks['activemq_cert:keystore']
      }
      datacat_fragment{'ssl_context':
         target => $configfile,
         data   => { 
                      ssl =>
                        { 'keyStore'         => "${configdir}/keystore.jks",
                          'keyStorePassword' => $keystore_pass
                        }

                   }

      }
   }

   # Set open files limit for activemq user.
   limits::entry { 'amq_nofiles_soft':
    domain => $amquser,
    type   => 'soft',
    item   => 'nofile',
    value  => $amqfilelimit,
    notify => Service['activemq']
   }
   limits::entry { 'amq_nofiles_hard':
    domain => $amquser,
    type   => 'hard',
    item   => 'nofile',
    value  => $amqfilelimit,
    notify => Service['activemq']
   }
   limits::entry { 'amq_nproc_soft':
    domain => $amquser,
    type   => 'soft',
    item   => 'nproc',
    value  => $amqproclimit,
    notify => Service['activemq']
   }
   limits::entry { 'amq_nproc_hard':
    domain => $amquser,
    type   => 'hard',
    item   => 'nproc',
    value  => $amqproclimit,
    notify => Service['activemq']
   }
}


