require 'api_constraints'

Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'
  root to: 'welcome#index'
  get 'dashboard' => 'dashboard#index', as: 'dashboard'

  resources :providers do
    resources :roles do
      resources :members, controller: 'subject_role_assignments',
                          only: %i(new create destroy)
      resources :api_members, controller: 'api_subject_role_assignments',
                              only: %i(new create destroy)

      resources :permissions, only: %i(index create destroy)
    end

    resources :provided_attributes do
      get :select_subject, on: :collection
    end

    resources :invitations, only: %i(new create) do
      get :redeliver, on: :member
    end

    resources :api_subjects do
      member do
        get 'audits' => 'api_subjects#audits', as: 'audit'
      end
    end

    resources :requested_enhancements, except: %i(edit update) do
      collection do
        get 'select' => 'requested_enhancements#select', as: 'select'
      end
      member do
        post 'dismiss' => 'requested_enhancements#dismiss', as: 'dismiss'
      end

      resources :provided_attributes, only: %i(new create destroy)
    end

    resources :provisioned_subjects, only: %i(edit update)
  end

  get 'request_enhancement' => 'requested_enhancements#select_provider',
      as: 'request_enhancement'

  resources :invitations, only: [] do
    collection do
      get 'complete' => 'invitations#complete'
      get ':identifier' => 'invitations#show', as: 'show'
      post ':identifier' => 'invitations#accept', as: 'accept'
    end
  end

  scope '/admin' do
    resources :invitations, only: %i(index)

    resources :available_attributes do
      collection do
        get 'audits' => 'available_attributes#audits', as: 'audit'
      end
      member do
        get 'audits' => 'available_attributes#audits', as: 'audit'
      end
    end

    resources :subjects, only: %i(index show destroy) do
      member do
        get 'audits' => 'subjects#audits', as: 'audit'
      end
    end

    resources :providers, only: [] do
      resources :permitted_attributes, only: %i(index create destroy)
    end
  end

  v1 = APIConstraints.new(version: 1, default: true)
  namespace :api, defaults: { format: 'json' } do
    scope 'subjects', constraints: v1 do
      get ':shared_token/attributes' => 'attributes#show',
          constraints: { shared_token: /[\w-]+/ }

      post 'attributes' => 'attributes#create'
    end
  end
end
