# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'get :index' do
    before { get :index }

    subject { response }

    it { is_expected.to be_successful }
    it { is_expected.to render_template('welcome/index') }
  end
end
