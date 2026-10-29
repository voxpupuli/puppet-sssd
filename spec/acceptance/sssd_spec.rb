# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'sssd' do
  # Module data for these releases makes sssd.conf group readable
  let(:group_readable) do
    (fact('os.name') == 'Debian' && fact('os.release.major') == '13') ||
      (fact('os.family') == 'RedHat' && fact('os.release.major') == '10')
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
