# frozen_string_literal: true
require 'rails_helper'

require 'gumboot/shared_examples/api_subjects'

RSpec.describe APISubject, type: :model do
  include_examples 'API Subjects'
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:api_subject) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:x509_cn) }
    it { is_expected.to validate_uniqueness_of(:x509_cn) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:contact_mail) }

    it { is_expected.to allow_value('abcd').for(:x509_cn) }
    it { is_expected.not_to allow_value('abcd!').for(:x509_cn) }
    it { is_expected.not_to allow_value("abc\ndef").for(:x509_cn) }
  end

  context 'associated objects' do
    context 'api_subject_role_assignments' do
      let(:child) { create(:api_subject_role_assignment) }
      subject { child.api_subject }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
