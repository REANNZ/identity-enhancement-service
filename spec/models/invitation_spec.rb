# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Invitation, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:invitation) }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_uniqueness_of(:identifier) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:mail) }
    it { is_expected.to validate_presence_of(:expires) }
    it { is_expected.to validate_presence_of(:last_sent_at) }

    it { is_expected.to allow_value('abcdefg1234').for(:identifier) }
    it { is_expected.not_to allow_value('abc!').for(:identifier) }
    it { is_expected.not_to allow_value("abc\ndef").for(:identifier) }

    it { is_expected.not_to allow_value(1.day.ago).for(:expires) }

    context 'when persisted' do
      subject { create(:invitation) }
      it { is_expected.to allow_value(1.day.ago).for(:expires) }
    end

    context '#subject' do
      let!(:other) { create(:invitation) }

      it 'is required to be unique' do
        expect { subject.subject = other.subject }
          .to change { subject.valid? }.to(false)
      end
    end
  end

  context '#expired?' do
    around { |e| Timecop.freeze { e.run } }

    subject! { create(:invitation, expires: expires) }
    let(:expires) { 1.second.from_now }

    context 'with `expires` in the future' do
      it { is_expected.not_to be_expired }
    end

    context 'with `expires` in the past' do
      around do |spec|
        subject
        Timecop.travel(1.minute) { spec.run }
      end

      it { is_expected.to be_expired }

      context 'when the invitation is used' do
        subject! { create(:invitation, used: true, expires: expires) }
        it { is_expected.not_to be_expired }
      end
    end
  end
end
