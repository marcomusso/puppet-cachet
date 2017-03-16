# == Class: cachet::apache
#
# Manages apache for cachet
#

class cachet::apache (
  $sslkey,
  $sslcert,
  $sslchain,
  $server_name,
  $install_dir,
  $purge_configs = false,
  ) {

  validate_string($sslkey)
  validate_string($sslcert)
  validate_string($sslchain)
  validate_string($server_name)
  validate_string($install_dir)

  class { '::apache':
    default_vhost => true,
    default_mods  => false,
    purge_configs => $purge_configs,
  }
  class { '::apache::mod::php':
    package_name => 'mod_php71w',
  }

  include ::apache::mod::ssl
  include ::apache::mod::dir
  include ::apache::mod::status
  include ::apache::mod::rewrite
  include ::apache::mod::autoindex
  include ::apache::mod::setenvif

  file { '/etc/httpd/conf.d/mydomain.key':
    owner   => 'apache',
    group   => 'apache',
    mode    => '0640',
    content => $sslkey,
  } ->
  file { '/etc/httpd/conf.d/mydomain.crt':
    owner   => 'apache',
    group   => 'apache',
    mode    => '0640',
    content => $sslcert,
  } ->
  file { '/etc/httpd/conf.d/chain.crt':
    owner   => 'apache',
    group   => 'apache',
    mode    => '0640',
    content => $sslchain,
  } ->
  ::apache::vhost { $server_name:
    servername    => $server_name,
    port          => 443,
    ssl           => true,
    ssl_key       => '/etc/httpd/conf.d/mydomain.key',
    ssl_cert      => '/etc/httpd/conf.d/mydomain.crt',
    ssl_chain     => '/etc/httpd/conf.d/chain.crt',
    docroot       => "${::cachet::install_dir}/public",
    docroot_owner => 'apache',
    docroot_group => 'apache',
    directories   => [
      {
        path           => "${::cachet::install_dir}/public",
        order          => 'Allow,Deny',
        allow          => 'from all',
        options        => ['Indexes','FollowSymLinks'],
        allow_override => ['All'],
        index_options  => ['FancyIndexing'],
      },
    ],
  }

  firewall { '280 apache':
    dport  => 80,
    proto  => 'tcp',
    state  => 'NEW',
    action => 'accept',
  }
  firewall { '244 apache ssl':
    dport  => 443,
    proto  => 'tcp',
    state  => 'NEW',
    action => 'accept',
  }
}
