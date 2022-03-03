# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class AccountTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :email_addresses,
           :user_preferences,
           :users

  def setup
    Setting.bcc_recipients = false
    ActionMailer::Base.deliveries.clear
  end

  def test_account_activation_request
    Setting.self_registration = '2'

    post(
      '/account/register',
      params: {
        user: {
          login: 'newuser',
          firstname: 'new',
          lastname: 'user',
          mail: 'newuser@somenet.foo',
          password: 'newpass123',
          password_confirmation: 'newpass123',
        },
      })

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'admin@somenet.foo', ActionMailer::Base.deliveries[0].to
  end

  def test_lost_password
    post(
      '/account/lost_password',
      params: {
        mail: 'jsmith@somenet.foo',
      })

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'jsmith@somenet.foo', ActionMailer::Base.deliveries[0].to
  end

  def test_register
    Setting.self_registration = '1'

    post(
      '/account/register',
      params: {
        user: {
          login: 'newuser',
          firstname: 'new',
          lastname: 'user',
          mail: 'newuser@somenet.foo',
          password: 'newpass123',
          password_confirmation: 'newpass123',
        },
      })

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'newuser@somenet.foo', ActionMailer::Base.deliveries[0].to
  end
end
