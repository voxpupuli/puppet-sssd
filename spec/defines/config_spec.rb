# frozen_string_literal: true

require 'spec_helper'

describe 'sssd::config' do
  let(:pre_condition) do
    [
      'include sssd',
    ]
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:title) { 'name/var' }
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.not_to compile }
      end

      context 'with minimal params' do
        let(:title) { 'name/var' }
        let(:params) do
          {
            'stanzas' =>
              {
                'sssd' =>
                  {
                    'domains' => %w[c a b],
                    'services' => 'pam, nss',
                  },
                'pam' => { 'pam_gssapi_services' => 'sudo, sudo-i' },
                'nss' => { 'pwfield' => '*' },
                'domain/a' => {},
              },
          }
        end

        # it { pp catalogue.resources }
        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/sssd/conf.d/50-domain_a_nss_pam_sssd.conf').
            with_ensure('file').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_notify('Class[Sssd::Service]').
            with_content(%r{^\[sssd\]$}).
            with_content(%r{^domains=c, a, b$}).
            with_content(%r{^services=pam, nss$}).
            with_content(%r{^\[nss\]$}).
            with_content(%r{^pwfield=\*$}).
            with_content(%r{^\[pam\]$}).
            with_content(%r{^pam_gssapi_services=sudo, sudo-i$}).
            with_content(%r{^\[domain/a\]$})
        }
      end

      context 'with lots of params' do
        let(:title) { 'name/var' }
        let(:params) do
          {
            'owner' => 'sssd',
            'group' => 'sssd',
            'mode' => '0644',
            'order' => 20,
            'stanzas' =>
              {
                'sssd' =>
                  {
                    'domains' => %w[c a b],
                    'services' => 'pam, nss',
                  },
                'pam' => {},
              },
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/sssd/conf.d/20-pam_sssd.conf').
            with_ensure('file').
            with_owner('sssd').
            with_group('sssd').
            with_mode('0644').
            with_notify('Class[Sssd::Service]').
            with_content(%r{^\[sssd\]$}).
            with_content(%r{^domains=c, a, b$}).
            with_content(%r{^services=pam, nss$}).
            with_content(%r{^\[pam\]$})
        }
      end

      context 'with a specific filename' do
        let(:title) { 'name/var' }
        let(:params) do
          {
            'filename' => 'example.conf',
            'stanzas' =>
              {
                'sssd' =>
                  {
                    'domains' => %w[c a b],
                    'services' => 'pam, nss',
                  },
                'pam' => {},
              },
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/sssd/conf.d/example.conf').
            with_ensure('file').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_notify('Class[Sssd::Service]').
            with_content(%r{^\[sssd\]$}).
            with_content(%r{^domains=c, a, b$}).
            with_content(%r{^services=pam, nss$}).
            with_content(%r{^\[pam\]$})
        }
      end

      context 'with a forced filename' do
        let(:title) { 'name/var' }
        let(:params) do
          {
            'force_this_filename' => '/tmp/thing.conf',
            'stanzas' =>
              {
                'sssd' =>
                  {
                    'domains' => %w[c a b],
                    'services' => 'pam, nss',
                  },
                'pam' => {},
              },
          }
        end

        it {
          is_expected.to contain_file('/tmp/thing.conf').
            with_ensure('file').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_notify('Class[Sssd::Service]').
            with_content(%r{^\[sssd\]$}).
            with_content(%r{^domains=c, a, b$}).
            with_content(%r{^services=pam, nss$}).
            with_content(%r{^\[pam\]$})
        }
      end
    end
  end
end
