# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class DocumentsTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :documents,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users

  def setup
    Setting.plain_text_mail = true
    Setting.notified_events = ['document_added']
    ActionMailer::Base.deliveries.clear

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'document_added'
    @template.template = 'template'
    @template.save!
  end

  def test_document_add
    log_user('admin', 'admin')

    new_record(Document) do
      post(
        '/projects/ecookbook/documents',
        params: {
          document: {
            title: 'test',
            description: 'test',
            category_id: "1",
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].parts.first.body.encoded
  end

  def test_document_add_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    new_record(Document) do
      post(
        '/projects/ecookbook/documents',
        params: {
          document: {
            title: 'test',
            description: 'test',
            category_id: "1",
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].parts.first.body.encoded
  end
end
