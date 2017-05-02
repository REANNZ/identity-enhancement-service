# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context '#environment_string' do
    let(:string) { Faker::Lorem.sentence }

    before do
      allow(Rails.application.config)
        .to receive_message_chain(:ide_service, :environment_string)
        .and_return(string)
    end

    subject { helper.environment_string }
    it { is_expected.to eq(string) }
  end

  context '#application_version' do
    it 'is a valid semver version' do
      expect(helper.application_version)
        .to match(/^\d+\.\d+\.\d+([+-][a-zA-Z0-9\.-]+){0,2}$/)
    end
  end
end
