# frozen_string_literal: true

module RedmineMailTemplate
  module MailerPatch
    private

    def mail_template_find_project_by_container
      if @issue
        return @issue.project
      elsif @document
        return @document.project
      elsif @attachments
        return @attachments.first.container.project
      elsif @news
        return @news.project
      elsif @message && @message.is_a?(Message)
        return @message.project
      elsif @wiki_content
        return @wiki_content.project
      elsif @text && @project
        # for redmine_wiki_extensions
        return @project
      end

      nil
    end

    def mail_template_find_setting_by_project(project)
      return nil unless project
      return nil unless project.module_enabled?(:mail_template)
      return nil unless mail_template_notifiable

      tracker_id = @issue.tracker_id if @issue
      setting = project.mail_template
        .where(notifiable: mail_template_notifiable, tracker_id: tracker_id)
        .first
      if setting.blank? && @issue
        setting = project.mail_template
          .where(notifiable: mail_template_notifiable, tracker_id: nil)
          .first
      end

      setting
    end

    def mail_template_notifiable
      if @journal
        'issue_updated'
      elsif @issue
        'issue_added'
      elsif @document
        'document_added'
      elsif @attachments
        container = @attachments.first.container
        if container.is_a?(Document)
          'document_added'
        else
          'file_added'
        end
      elsif @comment
        'news_comment_added'
      elsif @news
        'news_added'
      elsif @message && @message.is_a?(Message)
        'message_posted'
      elsif @wiki_content
        if @wiki_content.version == 1
          'wiki_content_added'
        else
          'wiki_content_updated'
        end
      elsif @text && @project
        # for redmine_wiki_extensions
        'wiki_comment_added'
      else
        nil
      end
    end
  end

  module MailerPatch4
    include MailerPatch

    def self.included(base)
      base.class_eval do
        alias_method_chain(:mail, :mail_template)
      end
    end

    def mail_with_mail_template(headers={}, &block)
      project = mail_template_find_project_by_container
      setting = mail_template_find_setting_by_project(project)
      if setting
        mail_without_mail_template headers do |format|
          # rubocop:disable Rails/RenderInline
          format.text { render inline: setting.template }
          unless Setting.plain_text_mail?
            inline = setting.html
            inline = setting.template if inline.blank?
            format.html { render inline: inline }
          end
          # rubocop:enable Rails/RenderInline
        end
      else
        mail_without_mail_template(headers, &block)
      end
    end
  end

  module MailerPatch5
    include MailerPatch

    def mail(headers={}, &block)
      project = mail_template_find_project_by_container
      setting = mail_template_find_setting_by_project(project)
      if setting
        super headers do |format|
          # rubocop:disable Rails/RenderInline
          format.text { render inline: setting.template }
          unless Setting.plain_text_mail?
            inline = setting.html
            inline = setting.template if inline.blank?
            format.html { render inline: inline }
          end
          # rubocop:enable Rails/RenderInline
        end
      else
        super
      end
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  Mailer.prepend RedmineMailTemplate::MailerPatch5
else
  Mailer.include RedmineMailTemplate::MailerPatch4
end
