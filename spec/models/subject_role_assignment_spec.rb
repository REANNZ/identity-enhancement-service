# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SubjectRoleAssignment, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { create(:subject, :authorized).subject_role_assignments.first! }

    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:role) }

    it 'requires role to be unique per subject' do
      other = build(:subject_role_assignment,
                    role: subject.role, subject: subject.subject)

      expect(other).not_to be_valid
    end
  end
end
