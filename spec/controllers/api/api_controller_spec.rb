# frozen_string_literal: true

require 'rails_helper'

require 'gumboot/shared_examples/api_controller'

module API
  RSpec.describe APIController, type: :controller do
    include_examples 'API base controller'

    context 'making a bad request' do
      let(:api_subject) do
        create(:api_subject, :authorized, permission: 'api:attributes:read')
      end

      before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}".dup }

      controller(APIController) do
        def bad
          public_action
          raise(APIController::BadRequest, 'Test Exception')
        end
      end

      before do
        @routes.draw do
          get '/api/bad' => 'api/api#bad'
        end
      end

      before { get :bad }
      subject { response }
      let(:data) { JSON.parse(response.body) }

      it { is_expected.to have_http_status(:bad_request) }

      it 'responds with the message' do
        expect(data['message']).to match(/could not be successfully processed/)
      end

      it 'responds with the exception' do
        expect(data['error']).to match(/Test Exception/)
      end
    end
  end
end
