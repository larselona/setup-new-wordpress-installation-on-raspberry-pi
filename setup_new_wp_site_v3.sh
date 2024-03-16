#!/bin/bash

# Prompt for user input for configuration variables
echo "Enter the new site domain (e.g., test.local):"
read -r NEW_SITE_DOMAIN

echo "Enter the new database name:"
read -r DB_NAME

echo "Enter the new database username:"
read -r DB_USER

echo "Enter the new database password:"
read -r DB_PASSWORD

# Ask user if they want to install recommended plugins
echo "Do you want to install recommended plugins? [y/N]:"
read -r INSTALL_PLUGINS

# Variables for paths and files
WP_PATH="/var/www/$NEW_SITE_DOMAIN/public_html"
VHOST_FILE="/etc/apache2/sites-available/$NEW_SITE_DOMAIN.conf"
CLEANUP_SCRIPT="/var/www/$NEW_SITE_DOMAIN/cleanup_$NEW_SITE_DOMAIN.sh"

# Function to print an error and exit
error_exit() {
    echo "Error: $1" 1>&2
    exit 1
}

# Function to configure WordPress for direct filesystem access
configure_direct_access() {
    echo "Configuring WordPress for direct filesystem access..."
    echo "define('FS_METHOD', 'direct');" >> $WP_PATH/wp-config.php
}

# Function to set correct permissions and ownership
set_permissions_ownership() {
    echo "Setting correct permissions and ownership..."
    sudo find $WP_PATH -type d -exec chmod 755 {} \;
    sudo find $WP_PATH -type f -exec chmod 644 {} \;
    sudo chown -R www-data:www-data $WP_PATH
}

# Function to install and activate recommended plugins
install_plugins() {
    echo "Installing and activating recommended plugins..."
    # Add plugin installation commands here, for example:
    # wp plugin install wordpress-seo --activate --path=$WP_PATH || error_exit "Failed to install and activate Yoast SEO."
    # Repeat for other plugins

# Navigate to the WordPress installation directory
cd /var/www/$NEW_SITE_DOMAIN/public_html || error_exit "Failed to navigate to WordPress directory."

# Install and activate Yoast SEO
wp plugin install wordpress-seo --activate || error_exit "Failed to install and activate Yoast SEO."

# Install and activate Wordfence Security
wp plugin install wordfence --activate || error_exit "Failed to install and activate Wordfence Security."

# Install and activate W3 Total Cache
wp plugin install w3-total-cache --activate || error_exit "Failed to install and activate W3 Total Cache."

# Install and activate Contact Form 7
wp plugin install contact-form-7 --activate || error_exit "Failed to install and activate Contact Form 7."

# Install and activate Akismet Anti-Spam
wp plugin install akismet --activate || error_exit "Failed to install and activate Akismet Anti-Spam."

# Install and activate WooCommerce (only if you need eCommerce functionality)
wp plugin install woocommerce --activate || error_exit "Failed to install and activate WooCommerce."

# Install and activate Jetpack
wp plugin install jetpack --activate || error_exit "Failed to install and activate Jetpack."

# Install and activate Elementor Page Builder
wp plugin install elementor --activate || error_exit "Failed to install and activate Elementor Page Builder."

# Install and activate WPForms
wp plugin install wpforms-lite --activate || error_exit "Failed to install and activate WPForms."

# Install and activate UpdraftPlus WordPress Backup Plugin
wp plugin install updraftplus --activate || error_exit "Failed to install and activate UpdraftPlus WordPress Backup Plugin."

# Install and activate the Envato Market Plugin
wp plugin install envato-elements --activate || error_exit "Failed to install and activate the Envato Market plugin."


echo "Recommended WordPress plugins installed and activated."
}

# Main installation steps...
# Your existing script steps here for installation
# Step 1: Create a new directory for the site
echo "Creating website directory..."
sudo mkdir -p /var/www/$NEW_SITE_DOMAIN/public_html || error_exit "Failed to create website directory."
echo "Directory created at /var/www/$NEW_SITE_DOMAIN/public_html"

# Step 2: Set Permissions
echo "Setting directory permissions..."
sudo chown -R $USER:$USER /var/www/$NEW_SITE_DOMAIN/public_html || error_exit "Failed to set directory permissions."
sudo chmod -R 755 /var/www || error_exit "Failed to set permissions."

# Step 3: Download and Extract WordPress
echo "Downloading WordPress..."
wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress-latest.tar.gz || error_exit "Failed to download WordPress."
echo "Extracting WordPress..."
tar -xzf /tmp/wordpress-latest.tar.gz -C /var/www/$NEW_SITE_DOMAIN/public_html --strip-components=1 || error_exit "Failed to extract WordPress."
echo "WordPress extracted"

# Step 4: Configure Apache Virtual Host
echo "Configuring Apache virtual host..."
VHOST_FILE="/etc/apache2/sites-available/$NEW_SITE_DOMAIN.conf"

echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $NEW_SITE_DOMAIN
    DocumentRoot /var/www/$NEW_SITE_DOMAIN/public_html
    <Directory /var/www/$NEW_SITE_DOMAIN/public_html>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee $VHOST_FILE > /dev/null || error_exit "Failed to configure Apache virtual host."

sudo a2ensite $NEW_SITE_DOMAIN.conf > /dev/null || error_exit "Failed to enable site."
echo "Apache virtual host configured"

# Step 5: Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2 || error_exit "Failed to restart Apache."
echo "Apache restarted"

# Step 6: Create MySQL Database and User
echo "Creating MySQL database and user..."
sudo mysql -u root -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" || error_exit "Failed to create database."
sudo mysql -u root -e "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';" || error_exit "Failed to grant database permissions."
sudo mysql -u root -e "FLUSH PRIVILEGES;" || error_exit "Failed to flush privileges."
echo "Database and user created"

# Step 7: Use WP-CLI to create wp-config.php with unique keys and salts

echo "Configuring wp-config.php..."

# Define the WordPress installation path
WP_PATH="/var/www/$NEW_SITE_DOMAIN/public_html"

# Navigate to the WordPress directory
cd $WP_PATH || error_exit "Failed to navigate to WordPress directory."

# Check if wp-config.php already exists
if [ ! -f "wp-config.php" ]; then
    # Use WP-CLI to generate wp-config.php with database details and unique keys
    wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --locale="en_GB" --path="$WP_PATH" --skip-check --extra-php <<PHP
define( 'WP_DEBUG', false );
PHP
    echo "wp-config.php has been created and configured."
else
    echo "wp-config.php already exists."
fi

# Optionally, set file permissions for wp-config.php
# sudo chmod 640 $WP_PATH/wp-config.php

# Step before installing WordPress
# Assuming you've already set the variable NEW_SITE_DOMAIN
WP_DIR="/var/www/$NEW_SITE_DOMAIN/public_html"

# Ensure we're in the WordPress installation directory
cd $WP_DIR || error_exit "Failed to change directory to WordPress installation."

# Now run the wp core install command
echo "Installing WordPress..."
wp core install --url="$NEW_SITE_DOMAIN" --title="New WordPress Site" --admin_user="admin" --admin_password="admin_password" --admin_email="admin@example.com" || error_exit "Failed to install WordPress."
echo "WordPress installed successfully."

# After WordPress installation steps
configure_direct_access
set_permissions_ownership

if [[ $INSTALL_PLUGINS =~ ^[Yy]$ ]]; then
    install_plugins
fi

# Generating cleanup script
echo "Generating cleanup script at $CLEANUP_SCRIPT..."
cat <<EOF > $CLEANUP_SCRIPT
#!/bin/bash
echo "Reversing the installation for $NEW_SITE_DOMAIN..."
sudo rm -rf /var/www/$NEW_SITE_DOMAIN
sudo mysql -u root -e "DROP DATABASE ${DB_NAME//./_};"
sudo rm $VHOST_FILE
sudo a2dissite $NEW_SITE_DOMAIN.conf > /dev/null 2>&1
sudo systemctl reload apache2
echo "Cleanup complete. Installation reversed."
EOF

chmod +x $CLEANUP_SCRIPT
echo "Cleanup script created at $CLEANUP_SCRIPT."


echo "Setup complete! Visit http://$NEW_SITE_DOMAIN to complete the WordPress installation."
echo "Cleanup script created at $CLEANUP_SCRIPT. Run this script to reverse the installation."
