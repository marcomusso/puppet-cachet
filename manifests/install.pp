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
  }
  -> package { [
    'mod_php71w',
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
  }

  if ((getvar('cachet_version') != undef) and (versioncmp($git_branch, getvar('cachet_version')) > 0)) {
    notify { "A new version (${git_branch}) has been requested: upgrading.":
      withpath => true,
    }
    exec {'Enable maintenance mode':
      command => 'php artisan down',
      path    => '/usr/pgsql-9.6/bin:/usr/bin:/usr/sbin:/bin',
      cwd     => $install_dir,
    }
    -> vcsrepo { $install_dir:
      ensure   => present,
      provider => git,
      source   => $repo_url,
      revision => $git_branch,
      owner    => 'apache',
      group    => 'apache',
      require  => [
        Package['git'],
        Package['mod_php71w'],
      ],
    }
    -> exec {'Update prerequisites':
      command     => '/usr/local/bin/composer install --no-dev -o --no-scripts',
      path        => '/usr/pgsql-9.6/bin:/usr/bin:/usr/sbin:/bin',
      cwd         => $install_dir,
      environment => "COMPOSER_HOME=${install_dir}/.composer",  # needed by composer
    }
    -> exec {'Update application':
      command => 'php artisan app:update',
      path    => '/usr/pgsql-9.6/bin:/usr/bin:/usr/sbin:/bin',
      cwd     => $install_dir,
    }
    -> exec {'Disable maintenance mode':
      command => 'php artisan up',
      path    => '/usr/pgsql-9.6/bin:/usr/bin:/usr/sbin:/bin',
      cwd     => $install_dir,
    }
    -> exec {'Clean cache':
      command => 'rm -rf bootstrap/cache/*',
      path    => '/usr/pgsql-9.6/bin:/usr/bin:/usr/sbin:/bin',
      cwd     => $install_dir,
    }
  } else {
    notify { "No new version has been requetest, still using ${git_branch}.":
      withpath => true,
    }
    vcsrepo { $install_dir:
      ensure   => present,
      provider => git,
      source   => $repo_url,
      revision => $git_branch,
      owner    => 'apache',
      group    => 'apache',
      require  => [
        Package['git'],
        Package['mod_php71w'],
      ],
    }
    -> exec { 'Install Composer':
      command     => '/bin/curl -sS https://getcomposer.org/installer | /bin/php -- --install-dir=/usr/local/bin --filename=composer',
      unless      => '/bin/test -x /usr/local/bin/composer',
      environment => "HOME=${install_dir}",
    }
    -> exec { 'Install Cachet prerequisites':
      command     => '/bin/php /usr/local/bin/composer install --no-dev -o',
      environment => "COMPOSER_HOME=${install_dir}/.composer",  # needed by composer
      creates     => "${install_dir}/vendor",
      cwd         => $install_dir,
    }
  }

  file { '/etc/facter/facts.d/cachet_version.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "cachet_version=${git_branch}\n",
    require => Vcsrepo[$install_dir],
  }
}
