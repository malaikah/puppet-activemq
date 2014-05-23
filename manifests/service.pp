# == Class: activemq::service
# Starts the activemq service.

class activemq::service inherits activemq {
     
  # Restart service on configuration change
  # ActiveMQ 5.9 drops the need for this, 
  # version could be obtained from fact...
  $subscription = $amqrestart ? {
     true  => File[$configfile],
     false => undef
  }

  service{'activemq':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    subscribe  => $subscription
  }

}
