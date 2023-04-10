Rails.application.routes.draw do
  resources :admin_menus, only: [:index]
  resources :employee_menus, only: [:index]

  devise_for :employees, controllers: {
    sessions:      'employees/sessions',
    passwords:     'employees/passwords',
    registrations: 'employees/registrations'
  }

  devise_for :admins, controllers: {
    sessions:      'admins/sessions',
    passwords:     'admins/passwords',
    registrations: 'admins/registrations'
  }

  devise_scope :employee do
    root to: 'employees/sessions#new'
  end

  resources :employees, only: [:index, :show, :edit, :update] do
    member do
      get '/:year/:month', to: 'employees#date', as: 'employee_date'
    end
  end

  resources :work_times, only: [:edit, :update] do
    collection do
      post :clock_in
      post :clock_out
    end
  end
end
