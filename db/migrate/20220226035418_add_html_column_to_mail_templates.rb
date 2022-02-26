# frozen_string_literal: true

class AddHtmlColumnToMailTemplates < RedmineMailTemplate::Utils::Migration
  def change
    add_column(:mail_templates, :html, :string)
  end
end
