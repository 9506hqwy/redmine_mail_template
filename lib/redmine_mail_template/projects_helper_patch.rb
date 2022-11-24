# frozen_string_literal: true

module RedmineMailTemplate
  module ProjectsHelperPatch
    def mail_template_setting_tabs(tabs)
      action = {
        name: 'mail_template',
        controller: :mail_templates,
        action: :update,
        partial: 'mail_templates/show',
        label: :mail_template,
      }

      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end

  module ProjectsHelperPatch4
    include ProjectsHelperPatch

    def self.included(base)
      base.class_eval do
        alias_method_chain(:project_settings_tabs, :mail_template)
      end
    end

    def project_settings_tabs_with_mail_template
      mail_template_setting_tabs(project_settings_tabs_without_mail_template)
    end
  end

  module ProjectsHelperPatch5
    include ProjectsHelperPatch

    def project_settings_tabs
      mail_template_setting_tabs(super)
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  Rails.application.config.after_initialize do
    ProjectsController.send(:helper, RedmineMailTemplate::ProjectsHelperPatch5)
  end
else
  ProjectsHelper.include RedmineMailTemplate::ProjectsHelperPatch4
end
