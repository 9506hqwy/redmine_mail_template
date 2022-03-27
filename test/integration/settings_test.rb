# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class SettingsTest < Redmine::IntegrationTest
  include ActiveJob::TestHelper
  include Redmine::I18n

  fixtures :email_addresses,
           :user_preferences,
           :users

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    ActionMailer::Base.deliveries.clear
  end

  def test_password
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      post(
        '/settings/edit',
        params: {
          settings: {
            login_required: 1,
          },
        })
    end

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'admin@somenet.foo', ActionMailer::Base.deliveries[0].to
  end
end
