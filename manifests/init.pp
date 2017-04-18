# == Class: cachet
#
# Installs a Cachet status page
#
# === Parameters
#
# [*manage_repos*]
#   Bool. If this module should try to add repos (false).
#
# [*manage_apache*]
#   Bool. If this module should install and configure apache on port 80 and 443 (true).
#
# [*database_host*]
#   String. Database host (without port).
#
# [*database_port*]
#   String. Database port.
#
# [*database_name*]
#   String. Database name.
#
# [*database_user*]
#   String. Database user.
#
# [*database_password*]
#   String. Database password.
#
# [*database_prefix*]
#   String. Database prefix for objects. (default no prefix)
#
# [*repo_url*]
#   String. Full URL of the cachet repo.
#
# [*git_branch*]
#   String. the git ref/branch to the actual code.
#
# [*install_dir*]
#   String. Full path of installation directory for Cachet.
#
# [*server_name*]
#   String. The FQDN of the webserver vhost that will serve the application.
#
# [*mail_host*]
#   String. Your email relay host.
#

class cachet (
  $mail_host         = $::cachet::params::mail_host,
  $manage_repo       = $::cachet::params::manage_repo,
  $manage_apache     = $::cachet::params::manage_apache,
  $database_host     = $::cachet::params::database_host,
  $database_port     = $::cachet::params::database_port,
  $database_name     = $::cachet::params::database_name,
  $database_user     = $::cachet::params::database_user,
  $database_password = $::cachet::params::database_password,
  $database_prefix   = $::cachet::params::database_prefix,
  $repo_url          = $::cachet::params::repo_url,
  $git_branch        = $::cachet::params::git_branch,
  $install_dir       = $::cachet::params::install_dir,
  $server_name       = $::cachet::params::server_name,
  $sslkey            = $::cachet::params::sslkey,
  $sslcert           = $::cachet::params::sslcert,
  $sslchain          = $::cachet::params::sslchain,
  ) inherits cachet::params {

  validate_re($repo_url, '^https?:\/\/.+', 'repo_url must be a url')
  validate_bool($manage_repo)
  validate_bool($manage_apache)
  validate_string($git_branch)
  validate_string($mail_host)
  validate_re($install_dir, '^/.+','Install dir must be a full path')
  validate_string($server_name)

  class { '::cachet::install':
    repo_url    => $repo_url,
    git_branch  => $git_branch,
    install_dir => $install_dir,
    manage_repo => $manage_repo,
  }

  if $manage_apache {
    class { '::cachet::apache':
      server_name => $server_name,
      sslkey      => $sslkey,
      sslcert     => $sslcert,
      sslchain    => $sslchain,
      install_dir => $install_dir,
    }
  }

  class { '::cachet::config':
    server_name       => $server_name,
    install_dir       => $install_dir,
    mail_host         => $mail_host,
    database_host     => $database_host,
    database_port     => $database_port,
    database_name     => $database_name,
    database_user     => $database_user,
    database_password => $database_password,
    database_prefix   => $database_prefix,
  }

  Class['::cachet::install'] -> Class['::cachet::config'] ~> Class['::cachet']
}
