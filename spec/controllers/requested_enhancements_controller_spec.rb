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

    let(:req) { create(:requested_enhancement, provider: provider) }
    let(:other_req) { create(:requested_enhancement) }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('requested_enhancements/index') }

    it 'assigns the enhancements' do
      expect(assigns[:requested_enhancements]).to include(req)
    end

    it 'only assigns enhancements requested from the current provider' do
      expect(assigns[:requested_enhancements]).not_to include(other_req)
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

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('requested_enhancements/show') }

    it 'assigns the requested enhancement' do
      expect(assigns[:requested_enhancement]).to eq(req)
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

    def run
      post :create, provider_id: provider.id, requested_enhancement: attrs
    end

    it 'creates the requested enhancement' do
      expect { run }.to change(provider.requested_enhancements, :count).by(1)
    end

    context 'the response' do
      before { run }

      it 'redirects to the provider' do
        expect(response).to redirect_to(provider_path(provider))
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

    before { get :select_provider }

    it { is_expected.to have_http_status(:ok) }

    let(:template) { 'requested_enhancements/select_provider' }
    it { is_expected.to render_template(template) }

    it 'assigns the providers list' do
      expect(assigns[:providers]).to include(provider)
    end
  end
end
