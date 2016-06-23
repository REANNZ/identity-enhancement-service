# frozen_string_literal: true
require 'rails_helper'

RSpec.describe APISubjectsController, type: :controller do
  let(:provider) { create(:provider) }
  let(:user) do
    create(:subject, :authorized,
           permission: "providers:#{provider.id}:api_subjects:*")
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  let(:orig_attrs) { attributes_for(:api_subject).except(:audit_comment) }

  let!(:api_subject) do
    create(:api_subject, orig_attrs.merge(provider: provider))
  end

  context 'get :index' do
    before { get :index, provider_id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/index') }
    it { is_expected.to have_assigned(:api_subjects, include(api_subject)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) { nil }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'get :new' do
    before { get :new, provider_id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/new') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:api_subject, a_new(APISubject)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    def run
      post(:create, provider_id: provider.id, api_subject: attrs)
    end

    let(:attrs) { attributes_for(:api_subject) }
    subject { -> { run } }

    it { is_expected.to change(APISubject, :count).by(1) }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'the response' do
      before { run }
      subject { response }

      it { is_expected.to redirect_to(provider_api_subjects_path(provider)) }

      it 'assigns the api subject' do
        expect(assigns[:api_subject]).to be_an(APISubject)
      end

      context 'with invalid attributes' do
        let(:attrs) { attributes_for(:api_subject, x509_cn: 'not valid') }

        it { is_expected.to render_template('new') }

        it 'sets the flash message' do
          expect(flash[:error]).not_to be_nil
        end
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(APISubject, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'get :show' do
    before { get :show, provider_id: provider.id, id: api_subject.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/show') }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'get :edit' do
    before { get :edit, provider_id: provider.id, id: api_subject.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/edit') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'patch :update' do
    let(:attrs) { attributes_for(:api_subject).except(:audit_comment) }

    before do
      patch :update, provider_id: provider.id, id: api_subject.id,
                     api_subject: attrs
    end

    subject { response }

    it { is_expected.to redirect_to(provider_api_subjects_path(provider)) }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'with invalid attributes' do
      let(:attrs) { attributes_for(:api_subject, x509_cn: 'not valid') }

      it { is_expected.to render_template('edit') }

      it 'sets the flash message' do
        expect(flash[:error]).not_to be_nil
      end
    end

    context 'the api subject' do
      subject { api_subject.reload }
      it { is_expected.to have_attributes(attrs) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }

      context 'the api subject' do
        subject { api_subject.reload }
        it { is_expected.to have_attributes(orig_attrs) }
      end
    end
  end

  context 'post :destroy' do
    def run
      delete :destroy, provider_id: provider.id, id: api_subject.id
    end

    subject { -> { run } }

    it { is_expected.to change(APISubject, :count).by(-1) }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(provider_api_subjects_path(provider)) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(APISubject, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'get :audits' do
    before { get :audits, provider_id: provider.id, id: api_subject.id }

    let(:audit) { api_subject.audits.first }
    let(:other) { create(:api_subject) }
    let(:other_audit) { other.audits.last }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to have_assigned(:audits, include(audit)) }
    it { is_expected.to have_assigned(:api_subject, api_subject) }
    it { is_expected.not_to have_assigned(:audits, include(other_audit)) }
    it { is_expected.to render_template('api_subjects/audits') }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end
end
