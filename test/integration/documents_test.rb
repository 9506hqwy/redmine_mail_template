# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class DocumentsTest < Redmine::IntegrationTest
  include ActiveJob::TestHelper
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
    Setting.plain_text_mail = 1
    Setting.notified_events = ['document_added']
    ActionMailer::Base.deliveries.clear

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'document_added'
    @template.template = 'template'
    @template.html = 'html'
    @template.save!
  end

  def test_document_add
    log_user('admin', 'admin')

    perform_enqueued_jobs do
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
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal 'text/plain; charset=UTF-8', ActionMailer::Base.deliveries[0].content_type
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_document_add_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    perform_enqueued_jobs do
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
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal 'text/plain; charset=UTF-8', ActionMailer::Base.deliveries[0].content_type
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_document_add_template_html
    Setting.plain_text_mail = 0

    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    perform_enqueued_jobs do
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
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert ActionMailer::Base.deliveries[0].content_type.start_with?('multipart/alternative')
    assert_equal @template.template, ActionMailer::Base.deliveries[0].parts[0].body.encoded
    assert_include "<p>#{@template.html}</p>", ActionMailer::Base.deliveries[0].parts[1].body.encoded
  end

  def test_document_add_template_html_empty
    Setting.plain_text_mail = 0
    @template.html = ''
    @template.save!

    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    perform_enqueued_jobs do
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
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert ActionMailer::Base.deliveries[0].content_type.start_with?('multipart/alternative')
    assert_equal @template.template, ActionMailer::Base.deliveries[0].parts[0].body.encoded
    assert_include "<p>#{@template.template}</p>", ActionMailer::Base.deliveries[0].parts[1].body.encoded
  end
end
