require 'rails_helper'

RSpec.describe ProvidedAttributesController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: "providers:#{provider.id}:attributes:*")
  end

  let(:permitted_attribute) { create(:permitted_attribute) }
  let(:provider) { permitted_attribute.provider }
  let(:object) { create(:subject) }
  let(:other_object) { create(:subject) }

  let!(:provided_attribute) do
    create(:provided_attribute, permitted_attribute: permitted_attribute,
                                subject: object)
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :index' do
    before { get :index, provider_id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('provided_attributes/index') }
    it { is_expected.to have_assigned(:provider, provider) }
    it 'assigns the provided attributes' do
      expect(assigns[:provided_attributes]).to include(provided_attribute)
    end

    it 'assigns all subjects' do
      expect(assigns[:objects]).to contain_exactly(*Subject.all)
    end

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

  context 'get :select_subject' do
    let!(:object) { create(:subject) }

    before { get :select_subject, provider_id: provider.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('provided_attributes/select_subject') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:objects, include(object)) }
  end

  context 'get :new' do
    let!(:other_permitted) { create(:permitted_attribute, provider: provider) }

    before { get :new, provider_id: provider.id, subject_id: object.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('provided_attributes/new') }
    it { is_expected.to have_assigned(:provider, provider) }
    it { is_expected.to have_assigned(:object, object) }

    it 'assigns the permitted attributes' do
      expect(assigns[:permitted_attributes]).to include(other_permitted)
    end

    it 'excludes the attribute already provided' do
      expect(assigns[:permitted_attributes]).not_to include(permitted_attribute)
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    let(:attrs) do
      attributes_for(:provided_attribute,
                     permitted_attribute: permitted_attribute)
        .merge(subject_id: other_object.id,
               permitted_attribute_id: permitted_attribute.id)
    end

    def run
      post(:create, provider_id: provider.id, provided_attribute: attrs)
    end

    subject { -> { run } }

    it { is_expected.to change(ProvidedAttribute, :count).by(1) }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'the response' do
      before { run }
      subject { response }

      let(:url) do
        new_provider_provided_attribute_path(provider,
                                             subject_id: other_object.id)
      end

      it { is_expected.to redirect_to(url) }

      it 'sets the provided attribute' do
        expect(assigns[:provided_attribute]).to be_a(ProvidedAttribute)
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(ProvidedAttribute, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'with a mismatched permitted_attribute / provider' do
      let(:other_attribute) { create(:permitted_attribute) }

      let(:attrs) do
        attributes_for(:provided_attribute,
                       permitted_attribute: other_attribute)
          .merge(subject_id: other_object.id,
                 permitted_attribute_id: other_attribute.id)
      end

      it { is_expected.not_to change(ProvidedAttribute, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:bad_request) }
      end
    end
  end

  context 'delete :destroy' do
    def run
      delete :destroy, provider_id: provider.id, id: provided_attribute.id
    end

    subject { -> { run } }

    it { is_expected.to change(ProvidedAttribute, :count).by(-1) }
    it { is_expected.to have_assigned(:provider, provider) }

    context 'the response' do
      before { run }
      subject { response }

      let(:url) do
        new_provider_provided_attribute_path(provider, subject_id: object.id)
      end

      it { is_expected.to redirect_to(url) }

      it 'sets the provided attribute' do
        expect(assigns[:provided_attribute]).to eq(provided_attribute)
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(ProvidedAttribute, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'for a mismatched provided_attribute / provider' do
      let(:other_provided_attribute) { create(:provided_attribute) }

      def run
        delete :destroy, provider_id: provider.id,
                         id: other_provided_attribute.id
      end

      it { is_expected.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
