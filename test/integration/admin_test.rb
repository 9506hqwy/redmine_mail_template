# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class AdminTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :email_addresses,
           :user_preferences,
           :users

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    ActionMailer::Base.deliveries.clear
  end

  def test_test_email
    log_user('admin', 'admin')

    post('/admin/test_email')

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'admin@somenet.foo', ActionMailer::Base.deliveries[0].to
  end
end
