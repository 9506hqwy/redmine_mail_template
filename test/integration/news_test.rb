# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class NewssTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :comments,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :news,
           :projects,
           :roles,
           :users

  def setup
    Setting.plain_text_mail = 1
    Setting.notified_events = ['news_added', 'news_comment_added']
    ActionMailer::Base.deliveries.clear

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'news_added'
    @template.template = 'template'
    @template.save!

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'news_comment_added'
    @template.template = 'template'
    @template.save!
  end

  def test_news_add
    log_user('admin', 'admin')

    new_record(News) do
      post(
        '/projects/ecookbook/news',
        params: {
          news: {
            title: 'test',
            description: 'test',
            summary: "test",
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_news_add_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    new_record(News) do
      post(
        '/projects/ecookbook/news',
        params: {
          news: {
            title: 'test',
            description: 'test',
            summary: "test",
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_news_comment_add
    log_user('admin', 'admin')

    post(
      '/news/1/comments',
      params: {
        comment: {
          comments: "test",
        },
      })

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_news_comment_add_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    post(
      '/news/1/comments',
      params: {
        comment: {
          comments: "test",
        },
      })

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end
end
