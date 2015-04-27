require 'rails_helper'

RSpec.describe RequestedEnhancementsController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: "providers:#{provider.id}:attributes:*")
  end

  let(:provider) { create(:provider) }

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  shared_examples 'common requested_enhancements stuff' do
    context 'with no user' do
      let(:user) { nil }

      it { is_expected.to redirect_to('/auth/login') }
    end

    it 'assigns the provider' do
      expect(assigns[:provider]).to eq(provider)
    end
  end

  context 'get :index' do
    before { get :index, provider_id: provider.id }

    let!(:req) { create(:requested_enhancement, provider: provider) }
    let!(:other_req) { create(:requested_enhancement) }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('requested_enhancements/index') }

    it 'assigns the enhancement requests' do
      expect(assigns[:requested_enhancements]).to include(req)
    end

    it 'only assigns enhancements requests from the current provider' do
      expect(assigns[:requested_enhancements]).not_to include(other_req)
    end

    context 'when the request is actioned' do
      let!(:req) do
        create(:requested_enhancement, provider: provider, actioned: true,
                                       actioned_by: user)
      end

      it 'excludes the actioned request' do
        expect(assigns[:requested_enhancements]).not_to include(req)
      end
    end

    context 'with an unprivileged user' do
      let(:user) { create(:subject) }

      it { is_expected.to have_http_status(:forbidden) }
      it { is_expected.to render_template('errors/forbidden') }
    end

    include_examples 'common requested_enhancements stuff'
  end

  context 'get :show' do
    before { get :show, provider_id: provider.id, id: req.id }

    let(:req) { create(:requested_enhancement, provider: provider) }

    let(:permitted_attribute) do
      create(:permitted_attribute, provider: provider)
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('requested_enhancements/show') }

    it 'assigns the requested enhancement' do
      expect(assigns[:requested_enhancement]).to eq(req)
    end

    context 'with attributes provided' do
      let!(:attr) do
        create(:provided_attribute, permitted_attribute: permitted_attribute,
                                    subject: req.subject)
      end

      let!(:other_attr) do
        create(:provided_attribute, subject: req.subject)
      end

      it 'assigns the already-provided attributes' do
        expect(assigns[:provided_attributes]).to include(attr)
      end

      it 'excludes provided attributes from other providers' do
        expect(assigns[:provided_attributes]).not_to include(other_attr)
      end
    end

    context 'with an unprivileged user' do
      let(:user) { create(:subject) }

      it { is_expected.to have_http_status(:forbidden) }
      it { is_expected.to render_template('errors/forbidden') }
    end

    include_examples 'common requested_enhancements stuff'
  end

  context 'get :new' do
    let(:user) { create(:subject) }

    before { get :new, provider_id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('requested_enhancements/new') }

    it 'assigns the requested enhancement' do
      expect(assigns[:requested_enhancement]).to be_a_new(RequestedEnhancement)
    end

    include_examples 'common requested_enhancements stuff'
  end

  context 'post :create' do
    let(:user) { create(:subject) }
    let(:attrs) { { message: Faker::Lorem.paragraph } }

    let!(:provider_admin) do
      create(:subject).tap do |admin|
        role = create(:role, provider: provider)
        create(:subject_role_assignment, role: role, subject: admin)
        create(:permission, role: role, value: "providers:#{provider.id}:*")
        admin.reload
      end
    end

    def run
      post :create, provider_id: provider.id, requested_enhancement: attrs
    end

    it 'creates the requested enhancement' do
      expect { run }.to change(provider.requested_enhancements, :count).by(1)
    end

    context 'the response' do
      before { run }

      it 'redirects to the provider' do
        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets the flash message' do
        expect(flash[:success]).to eq('Your request for identity enhancement ' \
                                      "has been sent to #{provider.name}")
      end

      it 'sends an email' do
        pattern = /.*A request.+was submitted.+to request.+enhance.*/m

        expect(response).to have_sent_email.to(provider_admin.mail)
        expect(response).to have_sent_email.matching_body(pattern)
      end

      include_examples 'common requested_enhancements stuff'
    end
  end

  context 'post :dismiss' do
    def run
      post :dismiss, provider_id: provider.id, id: req.id,
                     requested_enhancement: attrs
    end

    let(:attrs) { { message: Faker::Lorem.paragraph } }
    let(:req) { create(:requested_enhancement, provider: provider) }

    it 'marks the request as actioned' do
      run
      expect(req.reload).to be_actioned
      expect(req.actioned_by).to eq(user)
    end

    context 'the response' do
      before { run }

      it 'redirects to the provider' do
        expect(response).to redirect_to([provider, :requested_enhancements])
      end

      it 'sets the flash message' do
        expect(flash[:success]).to eq("Request from #{req.subject.name} " \
                                      'has been dismissed.')
      end

      context 'with an unprivileged user' do
        let(:user) { create(:subject) }

        it { is_expected.to have_http_status(:forbidden) }
        it { is_expected.to render_template('errors/forbidden') }
      end

      include_examples 'common requested_enhancements stuff'
    end
  end

  context 'get :select_provider' do
    let(:user) { create(:subject) }
    let(:filter) { nil }
    let(:page) { nil }

    before { get :select_provider, filter: filter, page: page }

    it { is_expected.to have_http_status(:ok) }

    let(:template) { 'requested_enhancements/select_provider' }
    it { is_expected.to render_template(template) }

    it 'assigns the providers list' do
      expect(assigns[:providers]).to include(provider)
    end

    context 'with a filter' do
      let!(:matching_provider) do
        create(:provider, name: 'NOTHING ELSE MATCHES')
      end

      let(:filter) { 'NOTHING*ELSE*MATCHES' }

      it 'only includes the matching provider' do
        expect(assigns[:providers]).to contain_exactly(matching_provider)
      end

      it 'sets the filter' do
        expect(assigns[:filter]).to eq(filter)
      end
    end

    context 'pagination' do
      let!(:enough_providers_for_a_second_page) { create_list(:provider, 21) }

      let!(:first_provider) do
        create(:provider, name: 'aaaaaaaaaaa first provider')
      end

      context 'on the first page' do
        let(:page) { '1' }

        it 'includes the first provider' do
          expect(assigns[:providers]).to include(first_provider)
        end
      end

      context 'on the second page' do
        let(:page) { '2' }

        it 'excludes the first provider' do
          expect(assigns[:providers]).not_to include(first_provider)
        end
      end
    end

    context 'with a private provider' do
      let(:secret_squirrel) { create(:provider, public: false) }

      it 'excludes the provider' do
        expect(assigns[:providers]).not_to include(secret_squirrel)
      end

      context 'when the user has access' do
        let(:user) do
          create(:subject).tap do |user|
            role = create(:role, provider: secret_squirrel)
            create(:subject_role_assignment, subject: user, role: role)
          end
        end

        it 'includes the provider' do
          expect(assigns[:providers]).to include(secret_squirrel)
        end
      end
    end
  end
end
