# frozen_string_literal: true

class MailTemplate < ActiveRecord::Base
  belongs_to :project
  belongs_to :tracker

  validates :project, presence: true
  validates :notifiable, presence: true
  validates :template, presence: true
end
