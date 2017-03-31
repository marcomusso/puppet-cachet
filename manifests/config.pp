# == Class: cachet::config
#
# Product config
#

class cachet::config(
  $env_file,
  $install_dir,
  $server_name,
  $database_host,
  $database_port,
  $database_name,
  $database_user,
  $database_password,
  $database_prefix,
  ) {

  if $database_host != '' {
    validate_string($database_host)
    validate_string($database_name)
    validate_string($database_user)
    validate_string($database_password)
    validate_string($database_prefix)
  }

  # we create the sqlite file anyway as a fall back if the user didn't specify a DB_HOST for the .env file
  file { "${install_dir}/database/database.sqlite":
    ensure => present,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0664',
  }
  -> file { "${install_dir}/.env":
    ensure  => file,
    owner   => 'apache',
    group   => 'apache',
    mode    => '0640',
    content => $env_file,
    replace => false,
  }
  -> exec { 'Application install and key generation':
    command => "/bin/php artisan app:install && /bin/touch ${install_dir}/.APP-IS-INSTALLED",
    path    => '/usr/pgsql-9.6/bin:/usr/bin:/usr/sbin:/bin',
    cwd     => $install_dir,
    creates => "${install_dir}/.APP-IS-INSTALLED",
  }
  -> file { "${install_dir}/storage":
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0777',
  }

  cron { 'Process Cachet queue':
    command  => '/bin/php artisan schedule:run >/dev/null 2>&1',
    user     => 'apache',
    month    => '*',
    monthday => '*',
    hour     => '*',
    minute   => '*',
  }
}
