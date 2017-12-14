# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProvidersController, type: :controller do
  let(:user) { create(:subject, :authorized, permission: 'providers:*') }
  let(:orig_attrs) { attributes_for(:provider).except(:audit_comment) }
  let(:provider) { create(:provider, orig_attrs) }
  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :index' do
    let!(:provider) { create(:provider) }
    let(:filter) { nil }
    let(:page) { nil }
    before { get :index, filter: filter, page: page }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('providers/index') }
    it { is_expected.to have_assigned(:providers, include(provider)) }

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

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('providers/index') }
      it { is_expected.to have_assigned(:providers, include(provider)) }
    end

    context 'with no user' do
      let(:user) { nil }
      before { get :index }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'get :new' do
    before { get :new }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('providers/new') }
    it { is_expected.to have_assigned(:provider, a_new(Provider)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    def run
      post(:create, provider: attrs)
    end

    let(:attrs) { attributes_for(:provider) }
    subject { -> { run } }

    it { is_expected.to change(Provider, :count).by(1) }
    it { is_expected.to have_assigned(:provider, an_instance_of(Provider)) }

    context 'the response' do
      before { run }
      subject { response }

      it { is_expected.to redirect_to(assigns[:provider]) }

      context 'with invalid attributes' do
        let(:attrs) { attributes_for(:provider, identifier: 'not valid') }

        it { is_expected.to render_template('new') }
        it 'sets the flash message' do
          expect(flash[:error]).not_to be_nil
        end
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Provider, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'get :show' do
    before { get :show, id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('providers/show') }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'get :edit' do
    before { get :edit, id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('providers/edit') }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'patch :update' do
    let(:attrs) do
      attributes_for(:provider).slice(:name, :description, :identifier)
    end

    before { patch :update, id: provider.id, provider: attrs }
    subject { response }

    it { is_expected.to redirect_to(assigns[:provider]) }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'with invalid attributes' do
      let(:attrs) { attributes_for(:provider, identifier: 'not valid') }

      it { is_expected.to render_template('edit') }
      it 'sets the flash message' do
        expect(flash[:error]).not_to be_nil
      end
    end

    context 'the provider' do
      subject { provider.reload }
      it { is_expected.to have_attributes(attrs) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }

      context 'the provider' do
        subject { provider.reload }
        it { is_expected.to have_attributes(orig_attrs) }
      end
    end
  end

  context 'post :destroy' do
    def run
      delete :destroy, id: provider.id
    end

    let!(:provider) { create(:provider) }
    subject { -> { run } }

    it { is_expected.to change(Provider, :count).by(-1) }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(providers_path) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Provider, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end
end
