# == Define: activemq::user
#
# Updates activemq.xml and credentials file with an activemq
# user with password and list of groups.
#
# It adds an XML element
#
#   <authenticationUser username="bob" password="xyz" groups="admins,everyone"/>
#
# and a credential
#
#   bob.username=bob
#   bob.password=xyz
#
# === Parameters
#
# [*namespace]
#   This is the first portion of the user identifier used in credentials.properties. Defaults to $title.
#
# [*username*]
#   This "namevar" and is the ActiveMQ username to add.
#
# [*password*]
#   The password of the user.
#
# [*credentials*]
#   The java properties file with username and passwords
#   typically the file /etc/activem/credentials.properties
#
# [*configfile*]
#   ActiveMQ configuratioon, typically /etc/activemq/activemq.xml
#
# [*groups*]
#   An array of groups that the user should be a member of.
#
# === Examples
#
#  activemq::{'bob':
#    password => 'xyz',
#    groups   => ['admins','everyone']
#
# === Copyright
#
# Steve Traylen , CERN, steve.traylen@cern.ch
#
define activemq::user (
  $password, 
  $namespace    = undef, 
  $username     = $title,
  $credentials  = $::activemq::credentials,
  $configfile   = $::activemq::configfile, 
  $groups = [] 
) {
  validate_string($username)
  validate_string($password)
  validate_string($credentials)
  validate_string($configfile)
  validate_array($groups)
  
  # Logic to ensure backwards compatibility on adding a $user variable
  $real_namespace = $namespace ?{
    undef   => $username,
    default => $namespace,
  }
  validate_string($real_namespace)

  # Fragment for credentials file
  datacat_fragment{"credentials_${username}":
    target => $credentials,
    data   => { users =>
                [ {'namespace' => $real_namespace, 'username'  => $username, 'password'  => $password
                  }
                ]
              }
    }

  # Fragment for activemq.xml
  datacat_fragment{"users_${username}":
    target => $configfile,
    data   => { users =>
                [ {'namespace' => $real_namespace, 'username'  => $username, 'password'  => $password, 'groups'    => $groups
                  }
                ]
              }
  }
}

