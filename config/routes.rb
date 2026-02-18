Rails.application.routes.draw do
  root "dashboard#show"

  resources :workspaces, only: [] do
    resources :channels, only: :show, param: :id
  end

  resources :action_items, only: :update

  namespace :api do
    post "slack/events", to: "slack_events#create"
    post "summaries/generate", to: "summaries#generate"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
