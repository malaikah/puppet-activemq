# == Define: activemq::auth
#
#  Creates authorizationEntry entities in the activemq.xml file e.g.
#
#    <authorizationEntry queue=">" write="admins" read="admins" admin="admins" />
#    <authorizationEntry topic=">" write="admins" read="admins" admin="admins" />
#    <authorizationEntry topic="ActiveMQ.Advisory.>" write="everyone" read="everyone" admin="everyone" />
#    <autizationEntry queue="*.nodes" write="mco" read="mco" admin="mco" />
#    <authorizationEntry queue="*.reply.>" write="mco" read="mco" admin="mco" />
#
# == Parameters
#
# [*path*]
#   The path of the topic of queue to match, e.g. 'x.y.z', 'x.y.*', '>', ...
#   The value defaults to the "namevar"
#
# [*configfile*]
#   The ActiveMQ configuration, typically /etc/activemq/activemq.xml
#
# [*type*]
#   Must be one of 'queue' or 'topic'
#
# [*read*]
#   An array of ActiveMQ groups who can read to the topic or queue.
#
# [*write*]
#   An array of ActiveMQ groups who can write to the topic or queue.
#
# [*admin*]
#   An array of ActiveMQ groups who can admin the topic or queue.
#
# === Examples
# Some authorizationEntries
# 
#   activemq::auth{'admin_queue':
#       type     => 'queue',
#       path     => '>',
#       write    => ['admins'],
#       read     => ['admins'],
#       admin    => ['admins']
#   }
#   activemq::auth{'admin_topic':
#       type     => 'topic',
#       path     => '>',
#       write    => ['admins'],
#       read     => ['admins'],
#       admin    => ['admins']
#   }
#   activemq::auth{'everyone_advise':
#       type     => 'topic',
#       path     => 'ActiveMQ.Advisory.>',
#       write    => ['everyone'],
#       read     => ['everyone'],
#       admin    => ['everyone']
#   }
#   activemq::auth{'mco_nodes':
#       type     => 'queue',
#       path     => '*.nodes',
#       write    => ['mco'],
#       read     => ['mco'],
#       admin    => ['mco']
#   }
#   activemq::auth{'mco_reply':
#       type     => 'queue',
#       path     => '*.reply.>',
#       write    => ['mco'],
#       read     => ['mco'],
#       admin    => ['mco']
#   }
#
# === Copyright
# Steve Traylen, CERN, 2014, steve.traylen@cern.ch
#
define activemq::auth ($type,$path=$title, $configfile = $::activemq::configfile, 
                       $read   = [],
                       $write  = [],
                       $admin  = []  )
{
  validate_string($path)
  validate_re($type,['^topic','^queue'],'The type of an auth must be a topic or a queue')
  validate_string($configfile)
  validate_array($admin)
  validate_array($write)
  validate_array($read)

  # Populate activemq file.
  datacat_fragment{"config_auth_${type}_${path}":
    target  => $configfile,
    data    => { paths =>
                 [ {'type'  => $type,
                    'path'  => $path,
                    'admin' => $admin,
                    'read'  => $read,
                    'write' => $write
                   }
                 ]
               }
  }
}

