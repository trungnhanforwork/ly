Rails.application.routes.draw do
  get '/health' => 'health#check'
  # ── JSON API ──
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_for :admin_users,
                 path: 'auth',
                 controllers: { sessions: 'api/v1/auth/sessions' },
                 path_names: { sign_in: 'sign_in', sign_out: 'sign_out' },
                 skip: %i[registrations passwords confirmations]

      resources :students do
        resource :metadata, controller: 'student_metadata'
        collection { post :scan_id_card }
        member     { get  :metadata, to: 'students#show_metadata' }
      end

      resources :certificates do
        resource :metadata, controller: 'certificate_metadata'
      end
    end
  end

  # ── ActiveAdmin (web) ──
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
