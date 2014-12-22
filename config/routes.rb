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
    end

    resources :provided_attributes
    resources :invitations, only: %i(new create)
    resources :api_subjects do
      member do
        get 'audits' => 'api_subjects#audits', as: 'audit'
      end
    end
  end

  resources :invitations, only: [] do
    collection do
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
    scope constraints: v1 do
      get 'attributes/:shared_token' => 'attributes#show',
          constraints: { shared_token: /[\w-]+/ }

      post 'attributes' => 'attributes#create'
    end
  end
end
