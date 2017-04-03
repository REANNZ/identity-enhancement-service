# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::AttributesController, type: :request do
  let(:api_subject) { create(:api_subject, :authorized) }
  let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}".dup } }

  subject { response }

  let(:json) { JSON.parse(response.body) }
  let(:object) { create(:subject) }

  # {
  #   "subject": {
  #     "shared_token": "W4ohH-6FCupmiBdwRv_w18AToQ",
  #     "mail": "john.doe@example.com",
  #     "name": "John Doe"
  #   },
  #   "attributes": [{
  #     "name":      "eduPersonEntitlement",
  #     "value":     "urn:mace:aaf.edu.au:ide:researcher:1"
  #     "provider":  "urn:mace:aaf.edu.au:ide:providers:provider1",
  #     "created":   "2015-01-01T00:00:00Z",
  #     "expires":   "2016-01-01T00:00:00Z"
  #   }, {
  #     "name":      "eduPersonEntitlement",
  #     "value":     "urn:mace:aaf.edu.au:ide:researcher:1"
  #     "provider":  "urn:mace:aaf.edu.au:ide:providers:provider2",
  #     "created":   "2015-01-01T00:00:00Z",
  #     "expires":   null
  #   }]
  # }
  context 'get /api/subjects/:shared_token/attributes' do
    def run
      get "/api/subjects/#{object.shared_token}/attributes", nil, headers
    end

    let(:json) { JSON.parse(response.body, symbolize_names: true) }
    let!(:provided_attribute) { create(:provided_attribute, subject: object) }
    let(:provider) { provided_attribute.permitted_attribute.provider }
    let(:expires) { 1.year.from_now }

    let!(:provisioned_subject) do
      create(:provisioned_subject, subject: object, provider: provider,
                                   expires_at: expires)
    end

    before { run }

    it { is_expected.to have_http_status(:ok) }

    context 'the subject identifier' do
      subject { json[:subject] }
      it { is_expected.to include(shared_token: object.shared_token) }
      it { is_expected.to include(name: object.name) }
      it { is_expected.to include(mail: object.mail) }
    end

    context 'the attribute list' do
      subject { json[:attributes] }
      it { is_expected.to contain_exactly(an_instance_of(Hash)) }
    end

    context 'the attribute entry' do
      subject { json[:attributes].first }

      before { run }

      let(:created) { provided_attribute.created_at }

      it { is_expected.to include(name: provided_attribute.name) }
      it { is_expected.to include(value: provided_attribute.value) }
      it { is_expected.to include(provider: provider.full_identifier) }
      it { is_expected.to include(expires: expires.utc.xmlschema) }
      it { is_expected.to include(created: created.utc.xmlschema) }

      context 'with no expiry' do
        let(:expires) { nil }
        it { is_expected.to include(expires: nil) }
      end
    end

    context 'attribute with multiple providers' do
      let(:other_permitted_attribute) do
        original = provided_attribute.permitted_attribute
        create(:permitted_attribute,
               available_attribute: original.available_attribute)
      end

      let(:other_provider) { other_permitted_attribute.provider }

      let(:other_provided_attribute) do
        create(:provided_attribute,
               permitted_attribute: other_permitted_attribute,
               subject: object)
      end

      def run
        other_provided_attribute
        super
      end

      context 'the attribute list' do
        subject { json[:attributes] }
        it { is_expected.to contain_exactly(*[an_instance_of(Hash)] * 2) }
      end

      context 'the attribute entry' do
        subject { json[:attributes].first }
        it { is_expected.to include(name: provided_attribute.name) }
        it { is_expected.to include(value: provided_attribute.value) }

        context 'providers' do
          let(:provider) { provided_attribute.permitted_attribute.provider }
          subject { json[:attributes].map { |a| a[:provider] } }

          it 'contains both providers' do
            expect(subject).to contain_exactly(provider.full_identifier,
                                               other_provider.full_identifier)
          end
        end
      end
    end

    context 'multiple attributes' do
      let!(:other_provided_attribute) do
        create(:provided_attribute, subject: object)
      end

      def run
        other_provided_attribute
        super
      end

      context 'the attribute list' do
        subject { json[:attributes] }
        it { is_expected.to contain_exactly(*([an_instance_of(Hash)] * 2)) }
      end

      context 'the first attribute entry' do
        let(:provider) { provided_attribute.permitted_attribute.provider }

        def find_in(list)
          list.find do |a|
            a[:provider] == provider.full_identifier &&
              a[:value] == provided_attribute.value
          end
        end

        subject { find_in(json[:attributes]) }

        it { is_expected.to include(name: provided_attribute.name) }
        it { is_expected.to include(value: provided_attribute.value) }
        it { is_expected.to include(provider: provider.full_identifier) }
      end

      context 'the other attribute entry' do
        let(:provider) do
          other_provided_attribute.permitted_attribute.provider
        end

        def find_in(list)
          list.find do |a|
            a[:provider] == provider.full_identifier &&
              a[:value] == other_provided_attribute.value
          end
        end

        subject { find_in(json[:attributes]) }

        it { is_expected.to include(name: other_provided_attribute.name) }
        it { is_expected.to include(value: other_provided_attribute.value) }
        it { is_expected.to include(provider: provider.full_identifier) }
      end
    end
  end

  context 'post /api/subjects/attributes' do
    # There's no response body to inspect, so this would be a duplicate of
    # spec/controllers/api/attributes_controller_spec.rb
  end
end
