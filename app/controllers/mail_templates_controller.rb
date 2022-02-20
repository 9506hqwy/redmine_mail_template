# frozen_string_literal: true

class MailTemplatesController < ApplicationController
  before_action :find_project_by_project_id, :authorize

  def update
    tracker_id = params[:mail_template_tracker_id].to_i if params[:mail_template_tracker_id].present?
    notifiable = params[:mail_template_notifiable]
    template = params[:mail_template_template]

    setting = @project.mail_template.find { |m| m.tracker_id == tracker_id && m.notifiable == notifiable }
    if template.blank? && setting.blank?
      # PASS
    elsif template.blank?
      if setting.destroy
        flash[:notice] = l(:notice_successful_update)
      end
    elsif !validate_template?(template)
      flash[:error] = l(:error_failure_invalid_template)
    else
      setting ||= MailTemplate.new
      setting.project_id = @project.id
      setting.tracker_id = tracker_id
      setting.notifiable = notifiable
      setting.template = template
      if setting.save
        flash[:notice] = l(:notice_successful_update)
      end
    end

    redirect_to settings_project_path(@project, tab: :mail_template)
  end

  private

  def validate_template?(template)
    if ActionView::VERSION::MAJOR >=5
      # rubocop:disable Security/Eval
      eval(ActionView::Template::Handlers::ERB::Erubi.new(template).src)
      # rubocop:enable Security/Eval
    else
      ActionView::Template::Handlers::Erubis.new(template).result
    end
  rescue SyntaxError
    return false
  rescue StandardError
    return true
  end
end
