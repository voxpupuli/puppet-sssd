# frozen_string_literal: true

require 'spec_helper'

describe 'sssd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('sssd') }
      it { is_expected.to contain_class('sssd::base_config').that_requires('Class[sssd::install]') }
      it { is_expected.to contain_class('sssd::service').that_subscribes_to('Class[sssd::base_config]') }
    end
  end
end
