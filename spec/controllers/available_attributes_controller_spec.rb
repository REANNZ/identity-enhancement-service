require 'rails_helper'

RSpec.describe AvailableAttributesController, type: :controller do
  let(:user) { create(:subject, :authorized, permission: 'admin:attributes:*') }
  let(:attribute) { create_attribute }

  def create_attribute
    attrs = attributes_for(:available_attribute)
    AvailableAttribute.create_with(audit_comment: 'test')
                      .find_or_create_by!(attrs.except(:audit_comment))
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :index' do
    let!(:attribute) { create_attribute }
    before { get :index }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('available_attributes/index') }
    it { is_expected.to have_assigned(:attributes, include(attribute)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
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
    it { is_expected.to render_template('available_attributes/new') }
    it { is_expected.to have_assigned(:attribute, a_new(AvailableAttribute)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    def run
      post(:create, available_attribute: attrs)
    end

    let(:attrs) { attributes_for(:available_attribute) }
    subject { -> { run } }

    it { is_expected.to change(AvailableAttribute, :count).by(1) }
    it do
      is_expected
        .to have_assigned(:attribute, an_instance_of(AvailableAttribute))
    end

    context 'the response' do
      before { run }
      subject { response }

      it { is_expected.to redirect_to(available_attributes_path) }

      context 'with invalid attributes' do
        let(:attrs) { attributes_for(:available_attribute, value: 'not valid') }

        it { is_expected.to render_template('new') }

        it 'sets the flash message' do
          expect(flash[:error]).not_to be_nil
        end
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(AvailableAttribute, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'get :show' do
    before { get :show, id: attribute.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('available_attributes/show') }
    it { is_expected.to have_assigned(:attribute, attribute) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'get :edit' do
    before { get :edit, id: attribute.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('available_attributes/edit') }
    it { is_expected.to have_assigned(:attribute, attribute) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'patch :update' do
    let(:attrs) do
      attributes_for(:available_attribute).slice(:name, :description, :value)
    end

    before { patch :update, id: attribute.id, available_attribute: attrs }
    subject { response }

    it { is_expected.to redirect_to(available_attributes_path) }
    it { is_expected.to have_assigned(:attribute, attribute) }

    context 'with invalid attributes' do
      let(:attrs) { attributes_for(:available_attribute, value: 'not valid') }

      it { is_expected.to render_template('edit') }

      it 'sets the flash message' do
        expect(flash[:error]).not_to be_nil
      end
    end

    context 'the available_attribute' do
      subject { attribute.reload }
      it { is_expected.to have_attributes(attrs) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :destroy' do
    def run
      delete :destroy, id: attribute.id
    end

    let!(:attribute) { create_attribute }
    subject { -> { run } }

    it { is_expected.to change(AvailableAttribute, :count).by(-1) }
    it { is_expected.to have_assigned(:attribute, attribute) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(available_attributes_path) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(AvailableAttribute, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'get :audits' do
    before { get :audits }
    let(:audit) { attribute.audits.first }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to have_assigned(:audits, include(audit)) }
    it { is_expected.to render_template('available_attributes/audits') }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with an id' do
      let(:other) { create(:available_attribute) }
      let(:other_audit) { other.audits.last }

      before { get :audits, id: attribute.id }

      it { is_expected.to have_assigned(:audits, include(audit)) }
      it { is_expected.not_to have_assigned(:audits, include(other_audit)) }
    end
  end
end
