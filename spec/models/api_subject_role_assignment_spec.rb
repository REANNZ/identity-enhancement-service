# frozen_string_literal: true
require 'rails_helper'

RSpec.describe APISubjectRoleAssignment, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { create(:api_subject_role_assignment) }

    it { is_expected.to validate_presence_of(:api_subject) }
    it { is_expected.to validate_presence_of(:role) }

    it 'requires role to be unique per api_subject' do
      other = build(:api_subject_role_assignment,
                    role: subject.role, api_subject: subject.api_subject)

      expect(other).not_to be_valid
    end
  end
end
