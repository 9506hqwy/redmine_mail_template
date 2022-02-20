# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  resources :projects do
    put '/mail_template', to: 'mail_templates#update', format: false
  end
end
