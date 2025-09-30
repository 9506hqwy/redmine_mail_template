# Redmine Mail Template

This plugin provides a mail body customization method per project.

## Installation

1. Download plugin in Redmine plugin directory.

   ```sh
   git clone https://github.com/9506hqwy/redmine_mail_template.git
   ```

2. Install plugin in Redmine directory.

   ```sh
   bundle exec rake redmine:plugins:migrate NAME=redmine_mail_template RAILS_ENV=production
   ```

3. Start Redmine

## Configuration

1. Enable plugin module.

   Check [Mail Template] in project setting.

2. Set in [Mail Template] tab in project setting.

   - [Email notifications]

     Select notification event.

   - [Tracker]

     Select tracker.

   - [Plain Text] tab or [HTML] tab

     Select mail format.

   - [Mail body]

     Input mail body ERB template.

     The default ERB template is [app/views/mailer](https://github.com/redmine/redmine/tree/master/app/views/mailer).

## Tested Environment

- Redmine (Docker Image)
  - 4.0
  - 4.1
  - 4.2
  - 5.0
  - 5.1
  - 6.0
  - 6.1
- Database
  - SQLite
  - MySQL 5.7 or 8.0
  - PostgreSQL 14

## References

- [#432 Custom Email templates, system wide and per project, through web interface.](https://www.redmine.org/issues/432)
- [#15615 customise the mail with a specific template](https://www.redmine.org/issues/15615)
