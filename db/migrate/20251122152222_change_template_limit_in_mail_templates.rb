# frozen_string_literal: true

class ChangeTemplateLimitInMailTemplates < RedmineMailTemplate::Utils::Migration
  def up
    change_column(:mail_templates, :template, :text)
    change_column(:mail_templates, :html, :text)
  end

  def down
    change_column(:mail_templates, :template, :string)
    change_column(:mail_templates, :html, :string)
  end
end
