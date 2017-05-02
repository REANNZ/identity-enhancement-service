# frozen_string_literal: true

require 'rails_helper'

require 'gumboot/shared_examples/roles'

RSpec.describe Role, type: :model do
  include_examples 'Roles'
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:role) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associated objects' do
    context 'api_subject_role_assignments' do
      let(:child) { create(:api_subject_role_assignment) }
      subject { child.role }
      it_behaves_like 'an association which cascades delete'
    end

    context 'subject_role_assignments' do
      let(:child) { create(:subject_role_assignment) }
      subject { child.role }
      it_behaves_like 'an association which cascades delete'
    end

    context 'permissions' do
      let(:child) { create(:permission) }
      subject { child.role }
      it_behaves_like 'an association which cascades delete'
    end
  end

  context 'associated objects' do
    context 'roles' do
      let(:child) { create(:role) }
      subject { child.provider }
      it_behaves_like 'an association which cascades delete'
    end

    context 'permitted_attributes' do
      let(:child) { create(:permitted_attribute) }
      subject { child.provider }
      it_behaves_like 'an association which cascades delete'
    end

    context 'api_subjects' do
      let(:child) { create(:api_subject) }
      subject { child.provider }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
