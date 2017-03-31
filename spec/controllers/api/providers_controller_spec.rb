# frozen_string_literal: true

require 'rails_helper'

module API
  RSpec.describe ProvidersController, type: :controller do
    let(:api_subject) { create(:api_subject) }
    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}".dup }

    context 'get :index' do
      let!(:provider) { create(:provider) }

      before { get :index, format: 'json' }

      subject { response }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/providers/index') }
      it { is_expected.to have_assigned(:providers, include(provider)) }

      context 'when the provider is hidden from the current user' do
        let!(:provider) { create(:provider, public: false) }

        it { is_expected.not_to have_assigned(:providers, include(provider)) }
      end
    end
  end
end
