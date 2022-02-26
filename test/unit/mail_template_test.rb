# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MailTemplateTest < ActiveSupport::TestCase
  fixtures :projects,
           :trackers

  def test_create
    p = projects(:projects_001)
    t = trackers(:trackers_001)

    m = MailTemplate.new
    m.project = p
    m.tracker = t
    m.notifiable = 'a'
    m.template = 'b'
    m.html = nil
    m.save!

    m.reload
    assert_equal p.id, m.project_id
    assert_equal t.id, m.tracker_id
    assert_equal 'a', m.notifiable
    assert_equal 'b', m.template
    assert_nil m.html
  end
end
