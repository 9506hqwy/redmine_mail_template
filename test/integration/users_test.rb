# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UsersTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :email_addresses,
           :user_preferences,
           :users

  def setup
    Setting.bcc_recipients = false
    ActionMailer::Base.deliveries.clear
  end

  def test_account_activated
    u = users(:users_002)
    u.status = User::STATUS_REGISTERED
    u.save!

    log_user('admin', 'admin')

    put(
      '/users/2',
      params: {
        user: {
          password: nil,
          status: User::STATUS_ACTIVE,
        },
      })

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'jsmith@somenet.foo', ActionMailer::Base.deliveries[0].to
  end

  def test_account_infomration
    log_user('admin', 'admin')

    put(
      '/users/2',
      params: {
        send_information: true,
        user: {
          password: nil,
        },
      })

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length

    assert_include 'jsmith@somenet.foo', ActionMailer::Base.deliveries[0].to
  end
end
