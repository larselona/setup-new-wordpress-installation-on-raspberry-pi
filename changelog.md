# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]



-/2. **SSL Configuration**: Automatically configure SSL for the site. This could involve requesting a Let's Encrypt certificate using `certbot` (if available) or providing instructions for configuring SSL manually.

-/3. **Backup Functionality**: Implement a function to create backups of the WordPress site and database before making significant changes. This could be a simple command line option to backup and restore.

-/4. **WordPress Configuration Wizard**: After installation, offer to run a post-installation wizard that sets up basic WordPress settings like site title, tagline, and visibility settings (discourage search engine visibility during development).

-/5. **Security Hardening**: Include options for basic security hardening, such as disabling file editing from the dashboard, setting up basic firewall rules, or configuring security plugins with recommended settings.

-/6. **Performance Optimization**: Provide options for installing and configuring caching plugins, setting up CDN integration, and optimizing images for performance.

-/7. **Theme Installation and Setup**: Allow users to specify a WordPress theme to install and activate during the setup process. This could extend to installing a list of themes and selecting which one to activate.

-/8. **Automatic Updates Configuration**: Offer to configure automatic updates for WordPress core, plugins, and themes, or set up a custom update schedule.

-/9. **Multi-site Configuration**: Add an option to set up WordPress in multi-site mode, with additional steps to configure the network settings.

-/10. **Log File Analysis**: Include a functionality to analyze log files for common errors and provide suggestions or fixes. This could be basic parsing of Apache/Nginx and WordPress debug logs.

-/11. **Email Configuration**: Assist in setting up outbound email functionality, either by configuring `sendmail`/`postfix` or by setting up a plugin for SMTP email delivery.

-/13. **Localization and Timezone Settings**: Prompt for localization settings such as language, timezone, and date format, applying these settings during WordPress setup.

-/14. **Database Optimization**: Implement a function to periodically optimize the WordPress database, reducing overhead and improving performance.

-/15. **Automated Testing**: Include basic automated tests to verify the successful installation of WordPress, plugins, and themes, and to check that the site is loading correctly.

Implementing these features would significantly enhance the utility of the script, making it a comprehensive tool for WordPress setup and management. Each feature would need to be carefully designed to fit into the workflow and to maintain the script's usability and reliability.
## [0.0.3] - 2024-03-18

### Added

- **Interactive Menu for Plugin Selection**: Instead of a binary choice for installing recommended plugins, provide an interactive menu where users can select which plugins to install. This allows for greater customization without manually editing the script.

## [0.0.2] - 2024-03-17

### Added

- **Staging Environment Setup**: Option to create a staging environment alongside the production site, allowing for safer testing of themes, plugins, and WordPress updates.

## [0.0.1] - 2024-03-17

- initial release

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
[unreleased]: https://github.com/Author/Repository/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/Author/Repository/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/Author/Repository/releases/tag/v0.0.1