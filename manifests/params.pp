# == Class dcachet::params
#
# It sets default variables.
#

class cachet::params {

  case $::osfamily {
    'RedHat': {
      $manage_repo       = false
      $manage_apache     = true
      $app_key           = ''
      $mail_host         = 'null'
      $mail_address      = 'null'
      $sslkey            = 'my ssl key'
      $sslcert           = 'my ssl cert'
      $sslchain          = 'my ssl chain'
      $server_name       = 'status.example.com'
      $database_host     = ''
      $database_port     = 'null'
      $database_name     = 'cachet'
      $database_user     = 'cachet'
      $database_password = 'not_so_secret_password'
      $database_prefix   = 'null'  # include an optional separator if you want (ie 'myprefix_'), null means no prefix
      $repo_url          = 'https://github.com/cachethq/Cachet.git'
      $git_branch        = 'v2.3.11'
      $install_dir       = '/opt/cachet'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
