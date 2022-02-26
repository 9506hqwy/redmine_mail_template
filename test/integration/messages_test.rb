# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MessagesTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :boards,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :messages,
           :projects,
           :roles,
           :users,
           :watchers

  def setup
    Setting.plain_text_mail = 1
    Setting.notified_events = ['message_posted']
    ActionMailer::Base.deliveries.clear

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'message_posted'
    @template.template = 'template'
    @template.save!
  end

  def test_message_posted
    log_user('admin', 'admin')

    new_record(Message) do
      post(
        '/boards/1/topics/new',
        params: {
          message: {
            subject: 'test',
            content: 'test',
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_message_posted_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    new_record(Message) do
      post(
        '/boards/1/topics/new',
        params: {
          message: {
            subject: 'test',
            content: 'test',
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end
end
