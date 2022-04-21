# frozen_string_literal: true

require 'spec_helper'

describe 'sssd::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(1) }
        it { is_expected.to contain_package('sssd').with_ensure('installed') }
      end

      describe 'without managed packages' do
        let(:params) do
          {
            'packages_manage' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(0) }
      end

      describe 'with args to install' do
        let(:params) do
          {
            'packages_manage' => true,
            'packages_ensure' => 'present',
            'package_names' => [ 'a', 'b' ],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(2) }
        it { is_expected.to contain_package('a').with_ensure('present') }
        it { is_expected.to contain_package('b').with_ensure('present') }
      end

      describe 'with args to update' do
        let(:params) do
          {
            'packages_manage' => true,
            'packages_ensure' => 'latest',
            'package_names' => [ 'a' ],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(1) }
        it { is_expected.to contain_package('a').with_ensure('latest') }
      end
    end
  end
end
