# WordPress Site Setup Script

This project contains a Bash script for automating the setup of a new WordPress site on a Linux server. It configures WordPress with sensible defaults, sets up a new Apache virtual host, creates a MySQL database, and optionally installs a set of recommended plugins. Additionally, it generates a cleanup script for each installation to easily reverse the setup.

## Features

- Automated WordPress download and configuration
- Apache virtual host setup
- MySQL database creation
- Optional WordPress plugin installation
- Direct file system access configuration for WordPress
- Automatic cleanup script generation

## Prerequisites

- A Linux server (tested on Debian GNU/Linux 12 (bookworm) on a raspberry pi)
- Apache2
- MySQL or MariaDB
- PHP (version 7.4 or higher recommended)
- WP-CLI installed on the server
- SSH access to the server

## Installation

1. Clone this repository to your server:
    ```bash
    git clone https://github.com/larselona/wordpress-setup-script.git
    ```
2. Navigate to the project directory:
    ```bash
    cd wordpress-setup-script
    ```
3. Make the script executable:
    ```bash
    chmod +x setup_new_wp_site_v3.sh
    ```

## Usage

Run the script and follow the interactive prompts to configure your new WordPress site:

```bash
./setup_new_wp_site_v3.sh
```

The login to the wp-admin is set to 'admin' with password 'admin_password'

To make the site accessible from a remote computer on your network the /etc/hosts file on the computer must be updated with
```bash
"ip address to the remote host" "name of new domain"
ex 192.168.1.130 new_site.local
```

## Options

You will be prompted to enter the site domain, database name, database username, and database password.
The script will ask if you want to install recommended plugins. Answer `y` for yes or simply press enter for no.

## Cleanup

After testing or if you need to remove the setup, run the generated cleanup script located in the site's directory:

```bash
/var/www/your_site_domain/cleanup_your_site_domain.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any improvements or bug fixes.

## License

This project is open-sourced under the MIT License. See the LICENSE file for more details.

## Acknowledgements

WordPress.org for the WordPress CMS
The developers of WP-CLI
All contributors to this project

