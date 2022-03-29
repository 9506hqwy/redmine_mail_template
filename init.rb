# frozen_string_literal: true

basedir = File.expand_path('../lib', __FILE__)
libraries =
  [
    'redmine_mail_template/mailer_patch',
    'redmine_mail_template/project_patch',
    'redmine_mail_template/projects_helper_patch',
    'redmine_mail_template/utils',
    'redmine_mail_template/tracker_patch',
  ]

libraries.each do |library|
  require_dependency File.expand_path(library, basedir)
end

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
