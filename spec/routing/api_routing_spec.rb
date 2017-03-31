# frozen_string_literal: true

require 'rails_helper'

module API
  RSpec.describe API, type: :routing do
    context AttributesController do
      context 'get /api/subjects/:shared_token/attributes' do
        let(:aepst) { SecureRandom.urlsafe_base64(19) }
        subject { { get: "/api/subjects/#{aepst}/attributes" } }
        it 'routes to api/subjects#show' do
          expect(subject).to route_to('api/attributes#show',
                                      shared_token: aepst, format: 'json')
        end
      end

      context 'get /api/subjects/:email_address/attributes' do
        subject { { get: "/api/subjects/#{Faker::Internet.email}/attributes" } }
        it { is_expected.not_to be_routable }
      end

      context 'post /api/subjects/attributes' do
        subject { { post: '/api/subjects/attributes' } }
        it { is_expected.to route_to('api/attributes#create', format: 'json') }
      end
    end

    context ProvidersController do
      context '/api/providers' do
        subject { { get: '/api/providers' } }
        it { is_expected.to route_to('api/providers#index', format: 'json') }
      end
    end
  end
end
