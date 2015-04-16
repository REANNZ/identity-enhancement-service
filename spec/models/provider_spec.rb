require 'rails_helper'

RSpec.describe Provider, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:provider) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_uniqueness_of(:identifier) }

    %W(aaf abcd1234_- #{'x' * 40}).each do |identifier|
      it { is_expected.to allow_value(identifier).for(:identifier) }
    end

    %W(aaf! abcd:1234 abc\ndef #{'x' * 41}).each do |identifier|
      it { is_expected.not_to allow_value(identifier).for(:identifier) }
    end
  end

  context '::lookup' do
    let(:provider) { create(:provider) }
    let(:prefix) { Rails.application.config.ide_service.provider_prefix }
    let(:identifier) { [prefix, provider.identifier].join(':') }

    it 'returns the provider' do
      expect(Provider.lookup(identifier)).to eq(provider)
    end

    it 'returns nil when missing' do
      expect(Provider.lookup(identifier + 'x')).to be_nil
    end
  end

  context '#full_identifier' do
    let(:provider) { create(:provider) }
    let(:prefix) { Rails.application.config.ide_service.provider_prefix }

    it 'calculates the identifier' do
      expect(provider.full_identifier)
        .to eq([prefix, provider.identifier].join(':'))
    end
  end

  context '#invite' do
    let(:user) { create(:subject) }
    let(:provider) { create(:provider) }
    let(:expires) { (1 + rand(10)).weeks.from_now }

    def run
      provider.invite(user, expires)
    end

    it 'creates the invitation' do
      expect { run }.to change(Invitation, :count).by(1)
    end

    it 'sets the user attributes' do
      run
      expect(user.invitation)
        .to have_attributes(name: user.name, mail: user.mail,
                            subject_id: user.id)
    end

    it 'sets the expiry' do
      Timecop.freeze do
        run
        expect(user.invitation.expires.to_i).to eq(expires.to_i)
      end
    end

    it 'returns the invitation' do
      expect(run).to be_an(Invitation)
    end
  end

  context '#create_default_roles' do
    let(:provider) { create(:provider) }

    def run
      provider.create_default_roles
    end

    it 'creates the roles' do
      expect { run }.to change(provider.roles, :count)
    end

    it 'replaces PROVIDER_ID with the actual id' do
      run
      expect(provider.roles.find_by_name('api_rw').permissions.map(&:value))
        .to include("providers:#{provider.id}:attributes:create")
    end
  end
end
