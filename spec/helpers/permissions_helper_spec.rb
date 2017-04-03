# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermissionsHelper, type: :helper do
  let(:helper) do
    klass = Class.new do
      attr_writer :subject
      include PermissionsHelper
    end
    klass.new
  end

  let(:user) { create(:subject, :authorized, permission: 'a:b:c') }
  before { helper.subject = user }

  context '#permitted?' do
    it 'returns true for a permit' do
      expect(helper.permitted?('a:b:c')).to be_truthy
    end

    it 'returns true for a deny' do
      expect(helper.permitted?('something:else')).to be_falsey
    end
  end
end
