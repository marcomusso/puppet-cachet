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
    # TODO add repo for postgres96 and exclude postgres for base repos
    #   On CentOS: /etc/yum.repos.d/CentOS-Base.repo, [base] and [updates] sections => exclude=postgresql*
    # Note: this requires epel
    package { 'Installs source yumrepo for postgres96':
      ensure => present,
      source => 'https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm',
    }
    exec { 'Add Webtatic GPG key':
      command => '/bin/curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-webtatic-el7 https://mirror.webtatic.com/yum/RPM-GPG-KEY-webtatic-el7',
      creates => '/etc/pki/rpm-gpg/RPM-GPG-KEY-webtatic-el7',
    } ->
    yumrepo { 'webtatic':
      ensure  => present,
      baseurl => 'https://repo.webtatic.com/yum/el7/x86_64/',
      enabled => true,
      gpgkey  => 'RPM-GPG-KEY-webtatic-el7',
    }
  }
  package { $prerequisites:
    ensure => latest,
  } ->
  package { [
    'php55w',
    'php55w-gd',
    'php55w-pdo',
    'php55w-xml',
    'php55w-pgsql',
    'php55w-mbstring',
    'php55w-opcache',
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
    command => '/bin/curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer',
    unless  => '/bin/test -x /usr/local/bin/composer',
  } ->
  exec { 'Install Cachet prerequisites':
    command     => '/bin/php /usr/local/bin/composer install --no-dev -o',
    environment => "COMPOSER_HOME=${install_dir}/.composer",  # needed by composer
    creates     => "${install_dir}/vendor",
    cwd         => $install_dir,
  }
}
