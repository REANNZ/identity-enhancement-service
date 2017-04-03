# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolesController, type: :controller do
  let(:user) { create(:subject, :authorized, permission: 'admin:roles:*') }
  let(:orig_attrs) { attributes_for(:role).except(:audit_comment, :provider) }
  let(:provider) { create(:provider) }
  let(:role) { create(:role, orig_attrs.merge(provider: provider)) }
  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :index' do
    let!(:role) { create(:role, provider: provider) }
    before { get :index, provider_id: provider.id }

    let(:user) do
      create(:subject, :authorized,
             permission: "providers:#{provider.id}:roles:*")
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('roles/index') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:roles, include(role)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) { nil }
      before { get :index, provider_id: provider.id }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'get :new' do
    before { get :new, provider_id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('roles/new') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:role, a_new(Role)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    def run
      post(:create, provider_id: provider.id, role: attrs)
    end

    let(:attrs) { attributes_for(:role) }
    subject { -> { run } }

    it { is_expected.to change(Role, :count).by(1) }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:role, an_instance_of(Role)) }

    context 'the response' do
      before { run }
      subject { response }

      it { is_expected.to redirect_to(provider_roles_path(provider)) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Role, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'get :show' do
    before { get :show, provider_id: provider.id, id: role.id }

    let(:user) do
      create(:subject, :authorized,
             permission: "providers:#{provider.id}:roles:*")
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('roles/show') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:role, role) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'get :edit' do
    before { get :edit, provider_id: provider.id, id: role.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('roles/edit') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:role, role) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'patch :update' do
    let(:attrs) { attributes_for(:role).slice(:name) }

    before do
      patch :update, provider_id: provider.id, id: role.id, role: attrs
    end

    subject { response }

    it { is_expected.to redirect_to(provider_roles_path(provider)) }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:role, role) }

    context 'the role' do
      subject { role.reload }
      it { is_expected.to have_attributes(attrs) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }

      context 'the role' do
        subject { role.reload }
        it { is_expected.to have_attributes(orig_attrs) }
      end
    end
  end

  context 'delete :destroy' do
    def run
      delete :destroy, provider_id: provider.id, id: role.id
    end

    let!(:role) { create(:role, provider: provider) }
    subject { -> { run } }

    it { is_expected.to change(Role, :count).by(-1) }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:role, role) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(provider_roles_path(provider)) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Role, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end
end
