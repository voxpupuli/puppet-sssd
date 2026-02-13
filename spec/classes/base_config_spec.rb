# frozen_string_literal: true

require 'spec_helper'

describe 'sssd::base_config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.to contain_file('/etc/sssd') }
        it { is_expected.to contain_file('/etc/sssd/pki') }
        it { is_expected.to contain_file('/etc/sssd/conf.d') }
        it { is_expected.to contain_sssd__config('/etc/sssd/sssd.conf') }
      end

      describe 'without managed config' do
        let(:params) do
          {
            'config_manage' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_file_resource_count(0) }
        it { is_expected.to have_sssd__config_resource_count(0) }
      end

      describe 'with args to manage everything' do
        let(:params) do
          {
            'config_manage' => true,
            'main_config_dir' => '/tmp',
            'main_pki_dir' => '/tmp/pki',
            'main_config_file' => '/tmp/test.conf',
            'config_d_location' => '/tmp/example',
            'purge_unmanaged_conf_d' => true,
            'pki_owner' => 'pki',
            'pki_group' => 'pki',
            'pki_mode' => '0711',
            'config_owner' => 'sssd',
            'config_group' => 'sssd',
            'config_mode' => '0755',
            'main_config' => { 'sssd' => { 'services' => ['pam'] } },
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_file_resource_count(4) }
        it { is_expected.to have_sssd__config_resource_count(1) }

        it {
          is_expected.to contain_file('/tmp').
            with_owner('sssd').
            with_group('sssd').
            with_mode('0755')
        }

        it {
          is_expected.to contain_file('/tmp/pki').
            with_owner('pki').
            with_group('pki').
            with_mode('0711')
        }

        it {
          is_expected.to contain_file('/tmp/example/').
            with_owner('sssd').
            with_group('sssd').
            with_mode('0755').
            with_recurse(true).
            with_purge(true)
        }

        it {
          is_expected.to contain_sssd__config('/tmp/test.conf').
            with_owner('sssd').
            with_group('sssd').
            with_mode('0755').
            with_stanzas({ 'sssd' => { 'services' => ['pam'] } })
        }
      end

      describe 'with minimal args' do
        let(:params) do
          {
            'purge_unmanaged_conf_d' => false,
            'main_config' => { 'sssd' => { 'services' => ['pam'] } },
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_file_resource_count(4) }
        it { is_expected.to have_sssd__config_resource_count(1) }

        it {
          is_expected.to contain_file('/etc/sssd/conf.d/').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_recurse(false).
            with_purge(false)
        }

        it {
          is_expected.to contain_sssd__config('/etc/sssd/sssd.conf').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_stanzas({ 'sssd' => { 'services' => ['pam'] } })
        }
      end

      describe 'with extra configs' do
        let(:params) do
          {
            'main_config' => { 'sssd' => { 'domains' => ['example'] } },
            'configs' =>
              {
                'pam' =>
                  {
                    'stanzas' => { 'sssd' => { 'services' => ['pam'] } }
                  },
                'nss' =>
                  {
                    'stanzas' => { 'sssd' => { 'services' => 'nss' } },
                    'order' => 30,
                  },
                'enable debug' =>
                  {
                    'stanzas' => { 'nss' => { 'debug' => 0 } }
                  }
              }
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_sssd__config_resource_count(4) }

        it {
          is_expected.to contain_sssd__config('/etc/sssd/sssd.conf').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_stanzas({ 'sssd' => { 'domains' => ['example'] } })
        }

        it {
          is_expected.to contain_sssd__config('pam').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_stanzas({ 'sssd' => { 'services' => ['pam'] } })
        }

        it {
          is_expected.to contain_sssd__config('nss').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_stanzas({ 'sssd' => { 'services' => 'nss' } }).
            with_order(30)
        }

        it {
          is_expected.to contain_sssd__config('enable debug').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_stanzas({ 'nss' => { 'debug' => 0 } })
        }
      end

      describe 'with advanced permissions' do
        let(:params) do
          {
            'advanced_permissions' => true,
            'configs' =>
              {
                'pam' =>
                  {
                    'stanzas' => { 'sssd' => { 'services' => ['pam'] } }
                  },
              }
          }
        end

        it {
          is_expected.to contain_file('/etc/sssd').
            with_owner('root').
            with_group('sssd').
            with_mode('0750')
        }

        it {
          is_expected.to contain_file('/etc/sssd/conf.d').
            with_owner('root').
            with_group('sssd').
            with_mode('0750')
        }

        it {
          is_expected.to contain_file('/etc/sssd/sssd.conf').
            with_owner('root').
            with_group('sssd').
            with_mode('0640')
        }

        it {
          is_expected.to contain_sssd__config('pam').
            with_owner('root').
            with_group('sssd').
            with_mode('0640').
            with_stanzas({ 'sssd' => { 'services' => ['pam'] } })
        }
      end
    end
  end
end
