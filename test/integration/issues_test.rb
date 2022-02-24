# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class IssuesTest < Redmine::IntegrationTest
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
           :watchers

  def setup
    Setting.plain_text_mail = true
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

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].parts.first.body.encoded
  end

  def test_issue_add_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

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

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].parts.first.body.encoded
  end

  def test_issue_edit
    log_user('admin', 'admin')

    put(
      '/issues/2',
      params: {
        issue: {
          subject: "test issue",
        }
      })

    # FIXME: 0 at test only in Redmine3
    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].parts.first.body.encoded
  end

  def test_issue_edit_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    put(
      '/issues/2',
      params: {
        issue: {
          subject: "test issue",
        }
      })

    # FIXME: 0 at test only in Redmine3
    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].parts.first.body.encoded
  end
end