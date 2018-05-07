require 'spec_helper'

describe 'cachet' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        describe "cachet class with parameters on #{os}" do
          let(:pre_condition) do
            '
            '
          end
          let(:params) do
            {
              'server_name' => 'status.example.com',
              'install_dir' => '/opt/cachet',
              'repo_url'    => 'http://github.com/...',
              'git_branch'  => 'v2.3.12',
            }
          end
          let(:facts) do
            facts.merge({
            })
          end
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('cachet') }

          # cachet::params
          it { is_expected.to contain_class('cachet::params') }

          # cachet::apache
          it { is_expected.to contain_package('mod_php72w') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/mydomain.key') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/mydomain.crt') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/chain.crt') }
          it { is_expected.to contain_apache__vhost(params['server_name'] + '_ssl').with({
            'docroot_owner' => 'apache',
            'docroot_group' => 'apache',
            }) }
          it { is_expected.to contain_apache__vhost(params['server_name']).with({
            'docroot_owner' => 'apache',
            'docroot_group' => 'apache',
            }) }
          it { is_expected.to contain_firewall('244 apache ssl') }
          it { is_expected.to contain_firewall('280 apache') }
          it { is_expected.to contain_class('cachet::apache') }

          # cachet::install
          context "If manage_repo is true" do
            let(:params) do
              {
                'manage_repo' => true,
              }
            end
            it { is_expected.to contain_package('pgdg-centos96-9.6-3.noarch') }
            it { is_expected.to contain_package('webtatic-release') }
          end
          it { is_expected.to contain_package('git') }
          it { is_expected.to contain_package('curl') }
          it { is_expected.to contain_package('sqlite') }
          it { is_expected.to contain_package('postgresql96') }
          it { is_expected.to contain_package('php72w-cli') }
          it { is_expected.to contain_package('php72w-gd') }
          it { is_expected.to contain_package('php72w-pdo') }
          it { is_expected.to contain_package('php72w-xml') }
          it { is_expected.to contain_package('php72w-pgsql') }
          it { is_expected.to contain_package('php72w-mbstring') }
          it { is_expected.to contain_package('php72w-opcache') }
          it { is_expected.to contain_vcsrepo('/opt/cachet').with_ensure('present') }
          it { is_expected.to contain_exec('Install Composer') }
          it { is_expected.to contain_exec('Install Cachet prerequisites') }
          it { is_expected.to contain_class('cachet::install') }
          it { is_expected.to contain_file('/etc/facter/facts.d/cachet_version.txt') }
          it { is_expected.to contain_notify('Installing version v2.3.12.') }

          # cachet::config
          it { is_expected.to contain_file('/opt/cachet/database/database.sqlite') }
          it { is_expected.to contain_file('/opt/cachet/.env') }
          it { is_expected.to contain_exec('Application install and key generation') }
          it { is_expected.to contain_file('/opt/cachet/storage').with_mode('0777') }
          it { is_expected.to contain_cron('Process Cachet queue') }
          it { is_expected.to contain_class('cachet::config') }
        end
      end
    end
  end
end
