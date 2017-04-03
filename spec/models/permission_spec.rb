# frozen_string_literal: true

require 'rails_helper'

require 'gumboot/shared_examples/permissions'

RSpec.describe Permission, type: :model do
  include_examples 'Permissions'

  context 'validations' do
    subject { build(:permission) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to allow_value('a').for(:value) }
    it { is_expected.to allow_value('a:b:c').for(:value) }
    it { is_expected.to allow_value('a:b:*').for(:value) }
    it { is_expected.to allow_value('a:*:c').for(:value) }
    it { is_expected.to allow_value('a:*:*').for(:value) }
    it { is_expected.to allow_value(Faker::Lorem.words.join(':')).for(:value) }
    it { is_expected.not_to allow_value('a:!b:c').for(:value) }
    it { is_expected.not_to allow_value('a:;b:c').for(:value) }
    it { is_expected.not_to allow_value("a:b\n:c").for(:value) }
  end
end
