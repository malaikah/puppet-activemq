#puppet-activemq

This is a activemq module to install and configure 
[ActiveMQ](http://activemq.apache.org/). The module includes
a number of defined types to additinally configure multiple extra elements
of an ActiveMQ service.

1. [activemq::auth](manifests/auth.pp) - Adds [authorizationEntry](http://activemq.apache.org/security.html) entities to an activemq.xml file.
2. [activemq::network](manifests/network.pp) - Adds [networkConnector](http://activemq.apache.org/networks-of-brokers.html) entities to an activemq.xml file.
3. [activemq::policy](manifests/policy.pp) - Adds [policyEntry](http://activemq.apache.org/security.html) entities to an activemq.xml file.
4. [activemq::transport](manifests/transport.pp) - Adds [transportConnector](http://activemq.apache.org/configuring-version-5-transports.html) entities to an activemq.xml file.
5. [activemq::user](manifests/user.pp) - Adds [authenticationUser](http://activemq.apache.org/security.html) entities to an activemq.xml file.

See each defined type for additional documentation as well [activemq::init](manifests/init.pp) for generic parameters.

## Example
This example is very much based on the [configuration of ActiveMQ](http://docs.puppetlabs.com/mcollective/deploy/middleware/activemq.html) 
for the [Mcollective](http://puppetlabs.com/mcollective) messaging application but hopefully ActiveMQ can be configured for other things
with this module.

```puppet
    # Install an activemq instance and configure various options
    # including a java keystore and nofile and nproc limits
    # for the activemq user.
    class{ 'activemq':
       amqmemory  => '2 gb',
       amqstore   => '10 gb',
       amqtemp    => '1 gb',
       max_memory => '36195', 
       dedicatedTaskRunner => false,
       keystore            => true,
       ca                  => '/etc/pki/tls/certs/MyCA-bundle.pem',
       amqrestart          => true,
       amqfilelimit        => '105000',
       amqproclimit        => '10240'

    }

    # Add activemq users
    activemq::user{'activemq':
        password => 'xyx'
        groups   => ['admins','everyone']
    }
    activemq::user{'mcclient':
        password => 'yut',
        groups   => ['mco','everyone']
    }

    activemq::user{'mcollective':
        password => 'yut'
        groups   => ['mco','everyone']
    }
    # Add authorization access for users to queues and topics.
    activemq::auth{'admin_queue':
        type     => 'queue',
        path     => '>',
        write    => ['admins'],
        read     => ['admins'],
        admin    => ['admins']
    }
    activemq::auth{'admin_topic':
        type     => 'topic',
        path     => '>',
        write    => ['admins'],
        read     => ['admins'],
        admin    => ['admins']
    }
    activemq::auth{'everyone_advise':
        type     => 'topic',
        path     => 'ActiveMQ.Advisory.>',
        write    => ['everyone'],
        read     => ['everyone'],
        admin    => ['everyone']
    }

    activemq::auth{'mco_agent':
        type     => 'topic',
        path     => '*.*.agent',
        write    => ['mco'],
        read     => ['mco'],
        admin    => ['mco']
    }
    activemq::auth{'mco_nodes':
        type     => 'queue',
        path     => '*.nodes',
        write    => ['mco'],
        read     => ['mco'],
        admin    => ['mco']
    }
    activemq::auth{'mco_reply':
        type     => 'queue',
        path     => '*.reply.>',
        write    => ['mco'],
        read     => ['mco'],
        admin    => ['mco']
    }


    # Add some transport connecters.
    activemq::transport{'stomp_nio_ssl':
        name     => 'stomp+nio+ssl',
        uri      => 'stomp+nio+ssl://0.0.0.0:61614'
    }
    # For interconnect between brokers.
    activemq::transport{'openwire':
        name     => 'openwire',
        uri      => 'tcp://0.0.0.0:61616'
    }

    # Some default policies for queues and topics.
    activemq::policy{'queues':
        type       => 'queue',
        path       => '*.reply.',
        attributes => { 'gcInactiveDestinations' => 'true',
                        'inactiveTimoutBeforeGC' => '300000',
                      }
    }
    activemq::policy{'topics':
        type       => 'topic',
        path       => '>',
        attributes => {'producerFlowControl' => 'false'}
    }

    # The following is to create uniplex network connecters between
    # two brokers , broker1 and broker2.
    $otherfqdn = $::fqdn ? {
       'broker1.example.org' => 'broker2.example.org',
       'broker2.example.org' => 'broker1.example.org',
    }
    activemq::network{"${::fqdn}-${otherfqdn}-topics":
        name                            => "${::fqdn}-${otherfqdn}-topics",
        uri                             => "static:(tcp://${otherfqdn}:61616)",
        username                        => 'activemq',
        password                        => 'xyz',
        duplex                          => false,
        decreaseNetworkConsumerPriority => true,
        networkTTL                      => '2',
        dynamicOnly                     => true,
        conduitSubscriptions            => true,
        excludedDestinationsType        => 'topic',
        excludedDestinationsPath        => '>'
    }
    activemq::network{"${::fqdn}-${otherfqdn}-queues":
        name                            => "${::fqdn}-${otherfqdn}-queues",
        uri                             => "static:(tcp://${otherfqdn}:61616)",
        username                        => 'activemq',
        password                        => 'xyz',
        duplex                          => false,
        decreaseNetworkConsumerPriority => true,
        networkTTL                      => '2',
        dynamicOnly                     => true,
        conduitSubscriptions            => false,
        excludedDestinationsType        => 'queue',
        excludedDestinationsPath        => '>'
    }
```

## Todo
* The current method that properties are set in activemq-wrapper.conf assumes
  an intial state of the activemq-wrapper.conf file. Should be improved.
* For the java keystore only a keystore is created but no truststore is created.
* Look at making this a pull request to the puppetlabs-activemq module. This
  is tricky currently as that module has a hardcoded mcollective 
  configuration which ideally would not be a default for the module.
  Would require a major version bump to puppetlabs-activemq module. 
  Also there are some variable name mismatches such as $configfile vs $config.
  Also java_ks stuff looks to be done in mcollective module so that has
  to be handled some how.

## License
Apache II license

## Contact
steve.traylen@cern.ch

## Support
Please log tickets and issues at our github page http://github.com/cernops/puppet-activemq

