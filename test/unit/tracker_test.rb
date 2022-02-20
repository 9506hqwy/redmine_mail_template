# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class TrackerTest < ActiveSupport::TestCase
  fixtures :trackers,
           :mail_templates

  def test_destroy
    Issue.where(tracker_id: 2).delete_all

    t = trackers(:trackers_002)
    t.destroy!

    begin
      mail_templates(:mail_templates_001)
      assert false
    rescue ActiveRecord::RecordNotFound
      assert true
    end
  end
end
