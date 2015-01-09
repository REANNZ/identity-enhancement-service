require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  # TODO: Replace this with actual required behaviour.
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
end
