# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermissionsController, type: :controller do
  let(:user) { create(:subject, :authorized, permission: 'admin:roles:*') }
  let(:permission) { create(:permission, value: 'a:*') }
  let(:role) { permission.role }
  let(:provider) { role.provider }

  before { session[:subject_id] = user.try(:id) }

  context 'get :index' do
    before { get :index, provider_id: provider.id, role_id: role.id }
    subject { response }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('permissions/index') }

    it 'assigns the provider' do
      expect(assigns[:provider]).to eq(provider)
    end

    it 'assigns the role' do
      expect(assigns[:role]).to eq(role)
    end

    it 'assigns the permissions' do
      expect(assigns[:permissions]).to include(permission)
    end

    it 'assigns a new permission' do
      expect(assigns[:new_permission]).to be_a_new(Permission)
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) { nil }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'post :create' do
    let(:attrs) { attributes_for(:permission, value: 'b:*') }

    def run
      post :create, provider_id: provider.id, role_id: role.id,
                    permission: attrs
    end

    subject { -> { run } }
    it { is_expected.to change(role.permissions, :count).by(1) }

    context 'the response' do
      before { run }
      subject { response }

      let(:url) { provider_role_permissions_path(provider, role) }
      it { is_expected.to redirect_to(url) }

      it 'sets the flash message' do
        expect(flash[:success]).to match('Added permission: b:*')
      end

      context 'with a failed save' do
        let(:attrs) { attributes_for(:permission, value: 'a:*') }

        it 'sets the flash message' do
          expect(flash[:error]).to match(/Unable to add permission: a:\*/)
        end
      end

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.to have_http_status(:forbidden) }
      end

      context 'with no user' do
        let(:user) { nil }
        it { is_expected.to redirect_to('/auth/login') }
      end
    end
  end

  context 'delete :destroy' do
    let!(:permission) { create(:permission) }

    def run
      delete :destroy, provider_id: provider.id, role_id: role.id,
                       id: permission.id
    end

    subject { -> { run } }

    it { is_expected.to change(role.permissions, :count).by(-1) }

    context 'the response' do
      before { run }
      subject { response }

      let(:url) { provider_role_permissions_path(provider, role) }
      it { is_expected.to redirect_to(url) }

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.to have_http_status(:forbidden) }
      end

      context 'with no user' do
        let(:user) { nil }
        it { is_expected.to redirect_to('/auth/login') }
      end
    end
  end
end
