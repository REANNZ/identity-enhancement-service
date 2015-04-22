require 'rails_helper'

RSpec.describe RequestedEnhancement, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_length_of(:message).is_at_most(4096) }

    context 'when not actioned' do
      subject { build(:requested_enhancement, actioned: false) }
      let(:user) { create(:subject) }

      it 'does not allow an actioned_by user' do
        expect { subject.actioned_by = user }
          .to change(subject, :valid?).from(true).to(false)
      end
    end

    context 'when not actioned' do
      subject { build(:requested_enhancement, actioned: true) }
      it { is_expected.to validate_presence_of(:actioned_by) }
    end
  end
end
