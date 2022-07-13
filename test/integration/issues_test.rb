# frozen_string_literal: true

require 'test_after_commit' if ActiveRecord::VERSION::MAJOR < 5
require File.expand_path('../../test_helper', __FILE__)

class IssuesTest < Redmine::IntegrationTest
  include ActiveJob::TestHelper
  include Redmine::I18n

  fixtures :email_addresses,
           :enabled_modules,
           :enumerations,
           :issues,
           :issue_statuses,
           :member_roles,
           :members,
           :projects,
           :projects_trackers,
           :roles,
           :users,
           :trackers,
           :versions,
           :watchers

  def setup
    Setting.plain_text_mail = 1
    Setting.notified_events = ['issue_added', 'issue_updated']
    ActionMailer::Base.deliveries.clear

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'issue_added'
    @template.template = 'template'
    @template.save!

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'issue_updated'
    @template.template = 'template'
    @template.save!
  end

  def test_issue_add
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Issue) do
        post(
          '/projects/ecookbook/issues',
          params: {
            issue: {
              tracker_id: '1',
              start_date: '2000-01-01',
              priority_id: "5",
              subject: "test issue",
            }
          })
      end
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_issue_add_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Issue) do
        post(
          '/projects/ecookbook/issues',
          params: {
            issue: {
              tracker_id: '1',
              start_date: '2000-01-01',
              priority_id: "5",
              subject: "test issue",
            }
          })
      end
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_issue_edit
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              subject: "test issue",
            }
          })
      end
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_issue_edit_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              subject: "test issue",
            }
          })
      end
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def put_issue_edit(&block)
    if ActiveRecord::VERSION::MAJOR >= 5
      yield
    else
      TestAfterCommit.with_commits(true, &block)
    end
  end
end
