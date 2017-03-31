# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvailableAttribute, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:available_attribute) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:value).scoped_to(:name) }

    it { is_expected.to allow_value('eduPersonEntitlement').for(:name) }
    it { is_expected.not_to allow_value(Faker::Lorem.word).for(:name) }

    let(:prefix) { 'urn:mace:aaf.edu.au:ide' }
    let(:suffix) { Faker::Lorem.words.join(':') }
    let(:value) { "#{prefix}:#{suffix}" }

    it { is_expected.to allow_value(value).for(:value) }
    it { is_expected.not_to allow_value(value.sub('ide', 'idp')).for(:value) }
  end

  context '::new' do
    subject { AvailableAttribute.new }
    let(:defaults) do
      { name: 'eduPersonEntitlement', value: 'urn:mace:aaf.edu.au:ide:' }
    end
    it { is_expected.to have_attributes(defaults) }
  end

  context '::audits' do
    let!(:attribute) { create(:available_attribute) }
    subject { AvailableAttribute.audits.all }
    it { is_expected.to include(attribute.audits.last) }
  end

  context 'associated objects' do
    context 'permitted_attributes' do
      let(:child) { create(:permitted_attribute) }
      subject { child.available_attribute }

      it 'prevents delete when a child object exists' do
        subject.audit_comment = 'Deleted to test association error'
        expect { subject.destroy! }
          .to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end
  end
end
