# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects,
           :mail_templates

  def test_destroy
    p = projects(:projects_005)
    p.destroy!

    begin
      mail_templates(:mail_templates_001)
      assert false
    rescue ActiveRecord::RecordNotFound
      assert true
    end
  end
end
