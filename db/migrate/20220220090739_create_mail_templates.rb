# frozen_string_literal: true

class CreateMailTemplates < RedmineMailTemplate::Utils::Migration
  def change
    create_table :mail_templates do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :notifiable, null: false
      t.belongs_to :tracker, foreign_key: true
      t.string :template, null: false

      t.index [:project_id, :notifiable, :tracker_id], name: 'mail_template_by_notifiable', unique: true
    end
  end
end
