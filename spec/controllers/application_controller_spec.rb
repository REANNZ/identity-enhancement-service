require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def good
      check_access!('permit')
      render nothing: true
    end

    def bad
      render nothing: true
    end

    def public
      public_action
      render nothing: true
    end

    def failed
      check_access!('deny')
      render nothing: true
    end

    before_action :require_subject, only: :force_authn
    def force_authn
      public_action
      render nothing: true
    end
  end

  before do
    @routes.draw do
      get '/anonymous/good' => 'anonymous#good'
      get '/anonymous/bad' => 'anonymous#bad'
      get '/anonymous/public' => 'anonymous#public'
      get '/anonymous/failed' => 'anonymous#failed'
      get '/anonymous/force_authn' => 'anonymous#force_authn'
    end
  end

  before { session[:subject_id] = user.id }
  let(:user) { create(:subject, :authorized, permission: 'permit') }

  context 'after_action hook' do
    it 'allows an action with access control' do
      expect { get :good }.not_to raise_error
    end

    it 'fails without access control' do
      msg = 'No access control performed by AnonymousController#bad'
      expect { get :bad }.to raise_error(msg)
    end

    it 'allows a public action' do
      expect { get :public }.not_to raise_error
    end
  end

  context '#check_access!' do
    it 'allows a permitted action' do
      get :good
      expect(response).to have_http_status(:ok)
    end

    it 'rejects a denied action' do
      get :failed
      expect(response).to have_http_status(:forbidden)
    end
  end

  context '#require_subject' do
    it 'forces authentication' do
      session[:subject_id] = nil
      get :force_authn
      expect(response).to redirect_to('/auth/login')
    end

    it 'allows an authenticated session through' do
      get :force_authn
      expect(response).to have_http_status(:ok)
    end

    it 'terminates the session if a subject disappears' do
      user.audit_comment = 'Deleted for test case'
      user.destroy!
      get :force_authn
      expect(response).to redirect_to('/auth/logout')
    end
  end
end
