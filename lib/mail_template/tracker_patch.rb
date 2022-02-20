# frozen_string_literal: true

module RedmineMailTemplate
  module TrackerPatch
    def self.prepended(base)
      base.class_eval do
        has_many :mail_template, dependent: :destroy
      end
    end
  end
end

Tracker.prepend RedmineMailTemplate::TrackerPatch
