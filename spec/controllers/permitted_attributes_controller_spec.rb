# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PermittedAttributesController, type: :controller do
  let(:user) do
    create(:subject, :authorized, permission: 'admin:permitted_attributes:*')
  end

  let(:provider) { create(:provider) }
  let!(:attribute) { create(:available_attribute) }
  let!(:permitted) { create(:permitted_attribute, provider: provider) }
  let(:return_url) { provider_permitted_attributes_path(provider) }

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :index' do
    before { get :index, provider_id: provider.id }

    it 'assigns the permitted attributes' do
      expect(assigns[:permitted_attributes]).to include(permitted)
    end

    it 'assigns the available attributes' do
      expect(assigns[:available_attributes]).to include(attribute)
    end

    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('permitted_attributes/index') }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'as a non-authenticated user' do
      let(:user) { nil }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'post :create' do
    let(:attrs) { { available_attribute_id: attribute.id } }

    def run
      post :create, provider_id: provider.id, permitted_attribute: attrs
    end

    subject { -> { run } }
    it { is_expected.to change(PermittedAttribute, :count).by(1) }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(return_url) }

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'delete :destroy' do
    def run
      delete :destroy, provider_id: provider.id, id: permitted.id
    end

    subject { -> { run } }
    it { is_expected.to change(PermittedAttribute, :count).by(-1) }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:permitted_attribute, permitted) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(return_url) }

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end
end
