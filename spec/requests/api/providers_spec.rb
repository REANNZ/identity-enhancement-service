# frozen_string_literal: true

require 'rails_helper'

module API
  RSpec.describe ProvidersController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}".dup } }
    let(:json) { JSON.parse(response.body, symbolize_names: true) }

    context 'get /api/providers' do
      def run
        get '/api/providers', nil, headers
      end

      let!(:provider) { create(:provider) }
      before { run }

      it 'lists the providers' do
        expect(json[:providers])
          .to include(name: provider.name, identifier: provider.full_identifier)
      end
    end
  end
end
