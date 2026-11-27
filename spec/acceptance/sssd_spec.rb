# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'sssd' do
  # Module data makes sssd.conf group readable where sssd >= 2.10
  let(:group_readable) do
    version = command('/usr/sbin/sssd --version').stdout[%r{\d+\.\d+}]
    Gem::Version.new(version) >= Gem::Version.new('2.10')
  end

  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<~PUPPET
        class { 'sssd':
          main_config => {
            'sssd'         => {
              'domains' => ['local'],
            },
            'domain/local' => {
              'id_provider'    => 'proxy',
              'proxy_lib_name' => 'files',
              'auth_provider'  => 'none',
            },
          },
        }
      PUPPET
    end
  end

  describe package('sssd') do
    it { is_expected.to be_installed }
  end

  describe file('/etc/sssd/sssd.conf') do
    it { is_expected.to be_file }
    it { is_expected.to be_mode(group_readable ? 640 : 600) }
    its(:content) { is_expected.to match(%r{^\[sssd\]\ndomains=local$}) }
    its(:content) { is_expected.to match(%r{^\[domain/local\]\nauth_provider=none\nid_provider=proxy\nproxy_lib_name=files$}) }
  end

  describe service('sssd') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end
