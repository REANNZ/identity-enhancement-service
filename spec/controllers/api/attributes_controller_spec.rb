require 'rails_helper'

module API
  RSpec.describe AttributesController, type: :controller do
    let(:api_subject) do
      role = create(:role, provider: provider)
      create(:permission, role: role, value: "providers:#{provider.id}:*")
      user = create(:api_subject, :authorized, permission: 'api:attributes:*')

      create(:api_subject_role_assignment, role: role, api_subject: user)
      user
    end

    let(:prefix) { Rails.application.config.ide_service.provider_prefix }
    let(:provider) { create(:provider) }
    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'get :show' do
      let!(:attributes) do
        create_list(:provided_attribute, 2, subject: object)
      end
      let(:object) { create(:subject) }

      before { get :show, format: 'json', shared_token: object.shared_token }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/attributes/show') }

      it 'assigns the attributes' do
        expect(assigns[:provided_attributes]).to contain_exactly(*attributes)
      end

      it 'assigns the subject' do
        expect(assigns[:object]).to eq(object)
      end

      context 'as a non-privileged user' do
        let(:api_subject) { create(:api_subject) }

        it { is_expected.to have_http_status(:forbidden) }

        it 'responds with a message' do
          data = JSON.load(response.body)
          expect(data['message']).to match(/explicitly denied/)
        end
      end
    end

    context 'post :create' do
      let(:permitted_attribute) { create(:permitted_attribute) }
      let(:provider) { permitted_attribute.provider }

      let(:provider_params) do
        { identifier: [prefix, provider.identifier].join(':') }
      end

      let(:attrs) do
        attribute = permitted_attribute.available_attribute
        [{ name: attribute.name, value: attribute.value }]
      end

      def run
        # {
        #   "subject": {
        #     "shared_token": "W4ohH-6FCupmiBdwRv_w18AToQ"
        #
        #     OR
        #
        #     "mail": "john.doe@example.com",
        #     "name": "John Doe"
        #   },
        #   "provider": {
        #     "identifier": "urn:mace:aaf.edu.au:ide:providers:provider1"
        #   },
        #   "attributes": [{
        #     "name":      "eduPersonEntitlement",
        #     "value":     "urn:mace:aaf.edu.au:ide:researcher:1",
        #
        #     OPTIONALLY:
        #     "public":    true
        #   }]
        # }
        post_params = { subject: subject_params, provider: provider_params,
                        attributes: attrs }
        post :create, post_params.merge(format: 'json')
      end

      before { run }
      subject { response }
      let(:response_data) { JSON.parse(response.body) }

      shared_examples 'attribute creation' do
        it { is_expected.to have_http_status(:no_content) }

        it 'creates the right attribute' do
          attribute = permitted_attribute.available_attribute
          expect(ProvidedAttribute.last)
            .to have_attributes(name: attribute.name,
                                value: attribute.value)
        end

        context 'when creating a public attribute' do
          let(:attrs) do
            attribute = permitted_attribute.available_attribute
            [{ name: attribute.name, value: attribute.value, public: true }]
          end

          it 'sets the public flag to true' do
            expect(ProvidedAttribute.last).to be_public
          end
        end

        context 'when creating a private attribute' do
          let(:attrs) do
            attribute = permitted_attribute.available_attribute
            [{ name: attribute.name, value: attribute.value, public: false }]
          end

          it 'sets the public flag to false' do
            expect(ProvidedAttribute.last).not_to be_public
          end
        end

        it 'creates a ProvisionedSubject' do
          object = assigns[:object]
          expect(object.provisioned_subjects.where(provider: provider))
            .to be_present
        end

        context 'with no provider identifier' do
          let(:provider_params) { nil }
          it_behaves_like 'attribute creation failure',
                          /Provider is not properly identified/
        end

        context 'as a non-privileged api_subject' do
          let(:api_subject) { create(:api_subject) }
          it { is_expected.to have_http_status(:forbidden) }
        end

        context 'using the wrong provider' do
          let(:other_provider) { create(:provider) }
          let(:provider_params) do
            { identifier: [prefix, other_provider.identifier].join(':') }
          end
          it { is_expected.to have_http_status(:forbidden) }
        end

        context 'using a non-permitted attribute' do
          let(:available_attribute) { create(:available_attribute) }
          let(:attrs) do
            [{ name: available_attribute.name,
               value: available_attribute.value }]
          end
          it { is_expected.to have_http_status(:bad_request) }

          it 'responds with an error message' do
            expect(response_data['error']).to match(/not permitted/)
            expect(response_data['error']).to include(available_attribute.name)
            expect(response_data['error']).to include(available_attribute.value)
          end
        end
      end

      shared_examples 'use of existing subject' do
        it 'assigns the subject' do
          expect(assigns[:object]).to eq(object)
        end
      end

      shared_examples 'invitation of new subject' do
        it 'assigns the subject' do
          expect(assigns[:object]).to eq(Subject.last)
        end

        it 'emails the invitation' do
          expect(response).to have_sent_email.to(object.mail)
        end
      end

      shared_examples 'attribute creation failure' do |message|
        it { is_expected.to have_http_status(:bad_request) }

        it 'responds with an error message' do
          expect(response_data['error']).to match(message)
        end
      end

      context 'with an existing subject' do
        let(:object) { create(:subject) }

        context 'identifying by shared token' do
          let(:subject_params) { { shared_token: object.shared_token } }

          include_examples 'attribute creation'
          include_examples 'use of existing subject'

          context 'creating an attribute which already exists' do
            let(:provided_attribute) do
              create(:provided_attribute,
                     subject: object, permitted_attribute: permitted_attribute)
            end

            def run
              provided_attribute
              expect { super }.not_to change(ProvidedAttribute, :count)
            end

            it { is_expected.to have_http_status(:no_content) }
          end

          context 'removing an attribute' do
            let(:provided_attribute) do
              create(:provided_attribute,
                     subject: object, permitted_attribute: permitted_attribute)
            end

            let(:attrs) do
              [{ name: provided_attribute.name,
                 value: provided_attribute.value,
                 _destroy: true }]
            end

            def run
              provided_attribute
              expect { super }.to change(ProvidedAttribute, :count).by(-1)
            end

            it { is_expected.to have_http_status(:no_content) }

            it 'deletes the provided attribute' do
              expect { provided_attribute.reload }
                .to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context 'removing an attribute which does not exist' do
            let(:provided_attribute) do
              build(:provided_attribute,
                    subject: object, permitted_attribute: permitted_attribute)
            end

            let(:attrs) do
              [{ name: provided_attribute.name,
                 value: provided_attribute.value,
                 _destroy: true }]
            end

            it { is_expected.to have_http_status(:no_content) }
          end
        end

        context 'identifying by name and email address' do
          let(:subject_params) { { name: 'Irrelevant', mail: object.mail } }

          include_examples 'attribute creation'
          include_examples 'use of existing subject'
        end

        context 'identifying by name' do
          let(:subject_params) { { name: object.name } }
          it_behaves_like 'attribute creation failure',
                          /Subject email address was not provided/
        end

        context 'identifying by email address' do
          let(:subject_params) { { mail: object.mail } }
          it_behaves_like 'attribute creation failure',
                          /Subject name was not provided/
        end
      end

      context 'inviting a new subject' do
        let(:object) { build(:subject) }

        context 'identifying by shared token' do
          let(:subject_params) { { shared_token: object.shared_token } }
          it_behaves_like 'attribute creation failure',
                          /Subject was not known to this system/
        end

        context 'identifying by name and email address' do
          let(:subject_params) do
            { name: object.name, mail: object.mail }
          end

          include_examples 'attribute creation'
          include_examples 'invitation of new subject'
        end

        context 'identifying by name' do
          let(:subject_params) { { name: object.name } }
          it_behaves_like 'attribute creation failure',
                          /Subject email address was not provided/
        end

        context 'identifying by email address' do
          let(:subject_params) { { mail: object.mail } }
          it_behaves_like 'attribute creation failure',
                          /Subject name was not provided/
        end

        context 'specifying the expiry' do
          let(:expires) { 8.weeks.from_now.to_date }

          let(:subject_params) do
            {
              name: object.name, mail: object.mail, expires: expires.iso8601
            }
          end

          it_behaves_like 'invitation of new subject'

          it 'expires the invitation when expected' do
            expect(Invitation.last.expires).to eq(expires)
          end
        end
      end
    end
  end
end
