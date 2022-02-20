# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

# user:2   ----->  project:1
#            role:1
#          ----->  project:2
#            role:2
#          ----->  project:5  ----->  mail_template:1
#            role:1

class MailTemplatesControllerTest < Redmine::ControllerTest
  include Redmine::I18n

  fixtures :member_roles,
           :members,
           :projects,
           :roles,
           :trackers,
           :users,
           :mail_templates

  def setup
    @request.session[:user_id] = 2

    role = Role.find(1)
    role.add_permission! :edit_mail_template
  end

  def test_update_create
    project = Project.find(1)
    project.enable_module!(:mail_template)

    put :update, params: {
      project_id: project.id,
      mail_template_tracker_id: '1',
      mail_template_notifiable: 'a',
      mail_template_template: 'b',
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/mail_template"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    m = project.mail_template.find { |m| m.tracker_id == 1 && m.notifiable == 'a' }
    assert_equal 'b', m.template
  end

  def test_update_update
    project = Project.find(5)
    project.enable_module!(:mail_template)

    put :update, params: {
      project_id: project.id,
      mail_template_tracker_id: '2',
      mail_template_notifiable: 'c',
      mail_template_template: 'd',
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/mail_template"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    m = project.mail_template.find { |m| m.tracker_id == 2 && m.notifiable == 'c' }
    assert_equal 'd', m.template
  end

  def test_update_destroy
    project = Project.find(5)
    project.enable_module!(:mail_template)

    put :update, params: {
      project_id: project.id,
      mail_template_tracker_id: '2',
      mail_template_notifiable: 'a',
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/mail_template"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    m = project.mail_template.find { |m| m.tracker_id == 2 && m.notifiable == 'a' }
    assert_nil m
  end

  def test_update_none
    project = Project.find(1)
    project.enable_module!(:mail_template)

    put :update, params: {
      project_id: project.id,
      mail_template_tracker_id: '1',
      mail_template_notifiable: 'a',
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/mail_template"
    assert_nil flash[:notice]
    assert_nil flash[:error]
  end

  def test_update_invalid_template
    project = Project.find(1)
    project.enable_module!(:mail_template)

    put :update, params: {
      project_id: project.id,
      mail_template_tracker_id: '1',
      mail_template_notifiable: 'a',
      mail_template_template: '<%= for %>'
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/mail_template"
    assert_nil flash[:notice]
    assert_not_nil flash[:error]
  end

  def test_update_deny_permission
    project = Project.find(2)
    project.enable_module!(:mail_template)

    put :update, params: {
      project_id: project.id,
      mail_template_tracker_id: '1',
      mail_template_notifiable: 'a',
    }

    assert_response 403
  end
end
