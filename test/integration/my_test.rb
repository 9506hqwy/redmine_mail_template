# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MyTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :email_addresses,
           :user_preferences,
           :users

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    ActionMailer::Base.deliveries.clear
  end

  def test_password
    log_user('jsmith', 'jsmith')

    post(
      '/my/password',
      params: {
        new_password: 'jsmithjsmith',
        new_password_confirmation: 'jsmithjsmith',
        password: 'jsmith',
      })

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'jsmith@somenet.foo', ActionMailer::Base.deliveries[0].to
  end
end
