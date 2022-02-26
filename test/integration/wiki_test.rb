# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class WikiTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :wiki_content_versions,
           :wiki_contents,
           :wiki_pages,
           :wikis

  def setup
    Setting.plain_text_mail = 1
    Setting.notified_events = ['wiki_content_added', 'wiki_content_updated']
    ActionMailer::Base.deliveries.clear

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'wiki_content_added'
    @template.template = 'template'
    @template.save!

    @template = MailTemplate.new
    @template.project_id = 1
    @template.notifiable = 'wiki_content_updated'
    @template.template = 'template'
    @template.save!
  end

  def test_wiki_content_added
    log_user('admin', 'admin')

    new_record(WikiContent) do
      put(
        '/projects/ecookbook/wiki/Wiki',
        params: {
          content: {
            text: "wiki content"
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_wiki_content_added_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    new_record(WikiContent) do
      put(
        '/projects/ecookbook/wiki/Wiki',
        params: {
          content: {
            text: "wiki content"
          }
        })
    end

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_wiki_content_updated
    log_user('admin', 'admin')

    put(
      '/projects/ecookbook/wiki/CookBook_documentation',
      params: {
        content: {
          text: "wiki content"
        }
      })

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_not_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end

  def test_wiki_content_updated_template
    Project.find(1).enable_module!(:mail_template)

    log_user('admin', 'admin')

    put(
      '/projects/ecookbook/wiki/CookBook_documentation',
      params: {
        content: {
          text: "wiki content"
        }
      })

    assert_not_equal 0, ActionMailer::Base.deliveries.length
    assert_equal @template.template, ActionMailer::Base.deliveries[0].body.encoded
  end
end
