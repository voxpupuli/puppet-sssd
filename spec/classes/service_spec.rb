# frozen_string_literal: true

require 'spec_helper'

describe 'sssd::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.to have_service_resource_count(1) }

        it {
          is_expected.to contain_service('sssd.service').
            with_ensure('running').
            with_enable(true)
        }
      end

      describe 'without management' do
        let(:params) do
          {
            'services_manage' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_service_resource_count(0) }
      end

      describe 'with interesting arguments' do
        let(:params) do
          {
            'services_manage' => true,
            'services_enable' => false,
            'services_ensure' => 'stopped',
            'service_names' => %w[a b]
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_service_resource_count(2) }

        it {
          is_expected.to contain_service('a').
            with_ensure('stopped').
            with_enable(false)
        }

        it {
          is_expected.to contain_service('b').
            with_ensure('stopped').
            with_enable(false)
        }
      end
    end
  end
end
