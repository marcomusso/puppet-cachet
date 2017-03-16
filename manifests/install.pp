# == Class: cachet::install
#
# Installs required packages
#

class cachet::install(
  $install_dir,
  $manage_repo,
  $repo_url,
  $git_branch,
  ) {

  # TODO: support updates (https://docs.cachethq.io/docs/updating-cachet)

  $prerequisites = [
    'git',
    'curl',
    'sqlite',
    'postgresql96',
  ]

  if $manage_repo {
    # TODO exclude postgres from base repos
    #   On CentOS: /etc/yum.repos.d/CentOS-Base.repo, [base] and [updates] sections => exclude=postgresql*
    package { 'pgdg-centos96-9.6-3.noarch':
      ensure   => present,
      provider => 'rpm',
      source   => 'https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm',
    }
    # Note: this requires epel
    package { 'webtatic-release':
      ensure   => present,
      provider => 'rpm',
      source   => 'https://mirror.webtatic.com/yum/el7/webtatic-release.rpm',
    }
  }
  package { $prerequisites:
    ensure => latest,
  } ->
  package { [
    'php71w-cli',
    'php71w-gd',
    'php71w-pdo',
    'php71w-xml',
    'php71w-pgsql',
    'php71w-mbstring',
    'php71w-opcache',
    ]:
    ensure => latest,
    notify => Class[Apache::Service],
  } ->
  vcsrepo { $install_dir:
    ensure   => present,
    provider => git,
    source   => $repo_url,
    revision => $git_branch,
    owner    => 'apache',
    group    => 'apache',
    require  => [ Package['git'] ],
  } ->
  exec { 'Install Composer':
    command     => '/bin/curl -sS https://getcomposer.org/installer | /bin/php -- --install-dir=/usr/local/bin --filename=composer',
    unless      => '/bin/test -x /usr/local/bin/composer',
    environment => "HOME=${install_dir}",
  } ->
  exec { 'Install Cachet prerequisites':
    command     => '/bin/php /usr/local/bin/composer install --no-dev -o',
    environment => "COMPOSER_HOME=${install_dir}/.composer",  # needed by composer
    creates     => "${install_dir}/vendor",
    cwd         => $install_dir,
  }
}
