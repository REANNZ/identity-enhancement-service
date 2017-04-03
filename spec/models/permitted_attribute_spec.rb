# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermittedAttribute, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:permitted_attribute) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:available_attribute) }

    it 'requires available_attribute to be unique per provider' do
      subject.save!
      other = build(:permitted_attribute,
                    available_attribute: subject.available_attribute,
                    provider: subject.provider)

      expect(other).not_to be_valid
    end
  end

  context 'associated objects' do
    context 'provided_attributes' do
      let(:child) { create(:provided_attribute) }
      subject { child.permitted_attribute }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
