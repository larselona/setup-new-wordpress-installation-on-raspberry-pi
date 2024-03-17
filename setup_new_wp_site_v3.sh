#!/bin/bash

initialize_and_prompt() {
    echo "Enter the new site domain (e.g., test.local):"
    read -r NEW_SITE_DOMAIN

    OVERVIEW_FILE="$(pwd)/${NEW_SITE_DOMAIN}_installation_overview.txt"

    echo "Installation Overview for $NEW_SITE_DOMAIN" > "$OVERVIEW_FILE"
    echo "------------------------------------------" >> "$OVERVIEW_FILE"
    date >> "$OVERVIEW_FILE"
    echo "" >> "$OVERVIEW_FILE"

    echo "Enter the new database name:"
    read -r DB_NAME

    echo "Enter the new database username:"
    read -r DB_USER

    echo "Enter the new database password:"
    read -r DB_PASSWORD

    echo "Do you want to install recommended plugins? [y/N]:"
    read -r INSTALL_PLUGINS

    echo "Configuration Variables:" >> "$OVERVIEW_FILE"
    echo "Site Domain: $NEW_SITE_DOMAIN" >> "$OVERVIEW_FILE"
    echo "Database Name: $DB_NAME" >> "$OVERVIEW_FILE"
    echo "Database Username: $DB_USER" >> "$OVERVIEW_FILE"
    echo "Database Password: [HIDDEN]" >> "$OVERVIEW_FILE"
    echo "Install Recommended Plugins: $INSTALL_PLUGINS" >> "$OVERVIEW_FILE"
    echo "" >> "$OVERVIEW_FILE"
}

define_variables() {
    WP_PATH="/var/www/$NEW_SITE_DOMAIN/public_html"
    VHOST_FILE="/etc/apache2/sites-available/$NEW_SITE_DOMAIN.conf"
    CLEANUP_SCRIPT="/var/www/$NEW_SITE_DOMAIN/cleanup_$NEW_SITE_DOMAIN.sh"
    WP_CLI_CACHE_DIR="/var/www/.wp-cli/cache"
}

setup_wp_cli_cache() {
    sudo mkdir -p "$WP_CLI_CACHE_DIR"
    sudo chown www-data:www-data "$WP_CLI_CACHE_DIR"
}

error_exit() {
    echo "Error: $1" 1>&2
    echo "$1" >> "$OVERVIEW_FILE"
    exit 1
}

configure_direct_access() {
    if ! grep -q "define('FS_METHOD', 'direct');" "$WP_PATH/wp-config.php"; then
        echo "define('FS_METHOD', 'direct');" >> "$WP_PATH/wp-config.php"
    fi
    echo "WordPress configured for direct filesystem access." >> "$OVERVIEW_FILE"
}

set_permissions_ownership() {
    sudo find "$WP_PATH" -type d -exec chmod 755 {} \;
    sudo find "$WP_PATH" -type f -exec chmod 644 {} \;
    sudo chown -R www-data:www-data "$WP_PATH"
    echo "Permissions and ownership set correctly." >> "$OVERVIEW_FILE"
}

create_website_directory() {
    echo "Creating website directory..."
    sudo mkdir -p "$WP_PATH" || error_exit "Failed to create website directory."
    echo "Directory created at $WP_PATH" >> "$OVERVIEW_FILE"
}

download_and_extract_wordpress() {
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress-latest.tar.gz || error_exit "Failed to download WordPress."
    
    # Ensure the target directory exists and is empty
    sudo mkdir -p "$WP_PATH" && sudo rm -rf "$WP_PATH/*"
    
    echo "Setting directory permissions before extraction..."
    # Adjust ownership and permissions more precisely
    sudo chown "$USER":"$USER" "$WP_PATH" || error_exit "Failed to set directory ownership to $USER."
    sudo chmod 755 "$WP_PATH" || error_exit "Failed to set directory permissions."

    echo "Extracting WordPress..."
    tar -xzf /tmp/wordpress-latest.tar.gz -C "$WP_PATH" --strip-components=1 || error_exit "Failed to extract WordPress."
    echo "WordPress extracted successfully" >> "$OVERVIEW_FILE"
    
    # Reset permissions to ensure the web server can access WordPress
    sudo chown -R www-data:www-data "$WP_PATH"
}




configure_apache_virtual_host() {
    echo "Configuring Apache virtual host..."
    echo "<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName $NEW_SITE_DOMAIN
        DocumentRoot $WP_PATH
        <Directory $WP_PATH>
            AllowOverride All
            Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>" | sudo tee $VHOST_FILE > /dev/null || error_exit "Failed to configure Apache virtual host."
    sudo a2ensite "$NEW_SITE_DOMAIN.conf" > /dev/null || error_exit "Failed to enable site."
    echo "Apache virtual host configured" >> "$OVERVIEW_FILE"
}

restart_apache() {
    echo "Restarting Apache..."
    sudo systemctl restart apache2 || error_exit "Failed to restart Apache."
    echo "Apache restarted" >> "$OVERVIEW_FILE"
}

create_mysql_database_and_user() {
    echo "Creating MySQL database and user..."
    sudo mysql -u root -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" || error_exit "Failed to create database."
    sudo mysql -u root -e "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';" || error_exit "Failed to grant database permissions."
    sudo mysql -u root -e "FLUSH PRIVILEGES;" || error_exit "Failed to flush privileges."
    echo "Database and user created" >> "$OVERVIEW_FILE"
}

install_and_configure_wordpress() {
    echo "Configuring wp-config.php..."
    if [ ! -f "$WP_PATH/wp-config.php" ]; then
        sudo -u www-data wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --path="$WP_PATH" --skip-check --extra-php <<PHP
define( 'WP_DEBUG', false );
PHP
        echo "wp-config.php has been created and configured." >> "$OVERVIEW_FILE"
    else
        echo "wp-config.php already exists." >> "$OVERVIEW_FILE"
    fi

    echo "Installing WordPress..."
    sudo -u www-data wp core install --url="$NEW_SITE_DOMAIN" --title="New WordPress Site" --admin_user="admin" --admin_password="admin_password" --admin_email="admin@example.com" --path="$WP_PATH" || error_exit "Failed to install WordPress."
    echo "WordPress installed successfully." >> "$OVERVIEW_FILE"
}

install_plugins() {
    if [[ $INSTALL_PLUGINS =~ ^[Yy]$ ]]; then
        echo "Installing and activating recommended plugins..."
        local plugins=("wordpress-seo" "wordfence" "w3-total-cache" "contact-form-7" "akismet" "woocommerce" "jetpack" "elementor" "wpforms-lite" "updraftplus" "envato-elements")
        for plugin in "${plugins[@]}"; do
            sudo -u www-data WP_CLI_CACHE_DIR="$WP_CLI_CACHE_DIR" wp plugin install "$plugin" --activate --path="$WP_PATH" || error_exit "Failed to install and activate $plugin."
            echo "$plugin plugin installed and activated." >> "$OVERVIEW_FILE"
        done
    fi
}

generate_cleanup_script() {
    echo "Generating cleanup script at $CLEANUP_SCRIPT..."

    # Use a temporary file to bypass permission issues, then move it to the desired location
    TMP_CLEANUP_SCRIPT="/tmp/cleanup_${NEW_SITE_DOMAIN}.sh"
    
    cat <<EOF > "$TMP_CLEANUP_SCRIPT"
#!/bin/bash
echo "Reversing the installation for $NEW_SITE_DOMAIN..."
sudo rm -rf "$WP_PATH"
sudo mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME;"
sudo rm "$VHOST_FILE"
sudo a2dissite "$NEW_SITE_DOMAIN.conf" > /dev/null 2>&1
sudo systemctl reload apache2
echo "Cleanup complete. Installation reversed."
EOF

    # Ensure the script has execute permissions
    chmod +x "$TMP_CLEANUP_SCRIPT"

    # Move the temporary cleanup script to the desired location with elevated permissions
    sudo mv "$TMP_CLEANUP_SCRIPT" "$CLEANUP_SCRIPT" || error_exit "Failed to create cleanup script."

    echo "Cleanup script created at $CLEANUP_SCRIPT." >> "$OVERVIEW_FILE"
}


finalize_installation() {
    echo "To update the /etc/hosts file on your MacBook Pro, please run the following command in your terminal:" >> "$OVERVIEW_FILE"
    echo "sudo -- sh -c 'echo \"192.168.1.130 $NEW_SITE_DOMAIN\" >> /etc/hosts'" >> "$OVERVIEW_FILE"
    echo "Setup complete! Visit http://$NEW_SITE_DOMAIN to complete the WordPress installation." >> "$OVERVIEW_FILE"
    echo "The installation overview has been saved to $OVERVIEW_FILE"
}

# Script execution
initialize_and_prompt
define_variables
setup_wp_cli_cache
configure_direct_access
set_permissions_ownership
create_website_directory
download_and_extract_wordpress
configure_apache_virtual_host
restart_apache
create_mysql_database_and_user
install_and_configure_wordpress
install_plugins
generate_cleanup_script
finalize_installation
