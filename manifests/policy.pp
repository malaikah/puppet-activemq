# == Define: activemq::policy
#
# Creates a policy entry in ActiveMQ configuration such as
#
# <policyEntry queue="*.reply."  gcInactiveDestinations="true"  inactiveTimoutBeforeGC="300000" />
#
# === Parameters
#
# [*path*]
#  The path is the topic or queue path to match, e.g 'a.b.c.*' or 'a.b.>'
#  The path is the "namevar".
#
# [*configfile*]
#  ActiveMQ configuration file, typically /etc/activemq/activemq.xml.
#
# [*type*]
#  Should be one of 'queue' or 'topic' and defines that this policy is
#  for a queue to topic.
#
# [*attributes*]
#  A hash of additional key value pairs that should be added as attributes
#  to the policyEntry.
#
# === Examples
# Add a queue and topic policy
#
#   activemq::policy{'queues':
#       type       => 'queue',
#       path       => '*.reply.',
#       attributes => { 'gcInactiveDestinations' => 'true',
#                       'inactiveTimoutBeforeGC' => '300000',
#                     }
#   }
#   activemq::policy{'topics':
#       type       => 'topic',
#       path       => '>',
#       attributes => {'producerFlowControl' => 'false'}
#   }
#
# === Copyright
# Steve Traylen, CERN, 2014, steve.traylen@cern.ch
#
define activemq::policy ($type, $path=$title, $configfile = $::activemq::configfile, $attributes = {})
{

  validate_string($path)
  validate_re($type,['^topic','^queue'],'The type of an auth must be a topic or a queue')
  validate_string($configfile)
  validate_hash($attributes)

  # Populate activemq file.
  datacat_fragment{"config_policy_${type}_${path}":
    target  => $configfile,
    data    => { policies =>
                 [ {'type'  => $type, 'path'  => $path, 'attributes' => $attributes
                   }
                 ]
               }
  }
}

