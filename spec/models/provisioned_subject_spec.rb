# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProvisionedSubject, type: :model do
  subject { create(:provisioned_subject) }

  context 'validations' do
    subject { build(:provisioned_subject) }

    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.not_to validate_presence_of(:expires_at) }

    it 'is unique on provider + subject' do
      create(:provisioned_subject, subject: subject.subject,
                                   provider: subject.provider)

      expect(subject).not_to be_valid
      expect(subject.errors[:provider]).to be_present
    end
  end
end
