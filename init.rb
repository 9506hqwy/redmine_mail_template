# frozen_string_literal: true

require_dependency 'mail_template/mailer_patch'
require_dependency 'mail_template/project_patch'
require_dependency 'mail_template/projects_helper_patch'
require_dependency 'mail_template/utils'
require_dependency 'mail_template/tracker_patch'

Redmine::Plugin.register :redmine_mail_template do
  name 'Redmine Mail Template plugin'
  author '9506hqwy'
  description 'This is a mail template plugin for Redmine'
  version '0.2.0'
  url 'https://github.com/9506hqwy/redmine_mail_template'
  author_url 'https://github.com/9506hqwy'

  project_module :mail_template do
    permission :edit_mail_template, { mail_templates: [:update] }
  end
end
