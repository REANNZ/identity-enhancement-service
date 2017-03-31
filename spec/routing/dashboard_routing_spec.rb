# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :routing do
  context 'get /dashboard' do
    subject { { get: '/dashboard' } }
    it { is_expected.to route_to('dashboard#index') }
  end
end
