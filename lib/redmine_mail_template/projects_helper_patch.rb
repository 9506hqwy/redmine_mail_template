# frozen_string_literal: true

module RedmineMailTemplate
  module ProjectsHelperPatch
    def project_settings_tabs
      action = {
        name: 'mail_template',
        controller: :mail_templates,
        action: :update,
        partial: 'mail_templates/show',
        label: :mail_template,
      }

      tabs = super
      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end
end

Rails.application.config.after_initialize do
  ProjectsController.send(:helper, RedmineMailTemplate::ProjectsHelperPatch)
end
