# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ProvidedAttribute, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    let(:attr) { subject.permitted_attribute.available_attribute }
    subject { build(:provided_attribute) }

    it { is_expected.to validate_presence_of(:permitted_attribute) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to allow_value(attr.name).for(:name) }
    it { is_expected.not_to allow_value(attr.name + 'a').for(:name) }
    it { is_expected.to allow_value(attr.value).for(:value) }
    it { is_expected.not_to allow_value(attr.value + 'a').for(:value) }

    it 'requires permitted_attribute to be unique per subject' do
      subject.save!
      other = build(:provided_attribute,
                    permitted_attribute: subject.permitted_attribute,
                    subject: subject.subject)

      expect(other).not_to be_valid
    end
  end

  context '::for_provider' do
    let!(:attribute) { create(:provided_attribute) }
    let(:provider) { attribute.permitted_attribute.provider }
    let(:other_provider) { create(:provider) }

    context 'with a matching provider' do
      subject { ProvidedAttribute.for_provider(provider) }
      it { is_expected.to include(attribute) }
    end

    context 'with a different provider' do
      subject { ProvidedAttribute.for_provider(other_provider) }
      it { is_expected.not_to include(attribute) }
    end
  end
end
