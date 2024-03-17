#!/bin/bash

echo "Scanning for WordPress installations..."

# Function to list WordPress sites
list_wp_sites() {
    for dir in /var/www/*; do
        if [ -d "$dir" ] && [ -f "$dir/public_html/wp-config.php" ]; then
            echo "$(basename "$dir")"
        fi
    done
}

# Function to duplicate a WordPress site
duplicate_site() {
    local source_site=$1
    local new_site_domain=$2
    local new_db_name=$3
    local new_db_user=$4
    local new_db_pass=$5

    local source_path="/var/www/$source_site/public_html"
    local new_path="/var/www/$new_site_domain/public_html"
    
    echo "Duplicating WordPress files..."
    cp -a "$source_path" "$new_path" || { echo "Failed to copy WordPress files."; exit 1; }
    
    echo "Creating new database..."
    mysql -u root -e "CREATE DATABASE $new_db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -e "GRANT ALL ON $new_db_name.* TO '$new_db_user'@'localhost' IDENTIFIED BY '$new_db_pass';"
    mysql -u root -e "FLUSH PRIVILEGES;"
    
    echo "Copying database..."
    wp db export --path="$source_path" --add-drop-table --allow-root | wp db import --path="$new_path" --allow-root
    
    echo "Updating wp-config.php..."
    sed -i "s/define('DB_NAME', '.*')/define('DB_NAME', '$new_db_name')/" "$new_path/wp-config.php"
    sed -i "s/define('DB_USER', '.*')/define('DB_USER', '$new_db_user')/" "$new_path/wp-config.php"
    sed -i "s/define('DB_PASSWORD', '.*')/define('DB_PASSWORD', '$new_db_pass')/" "$new_path/wp-config.php"
    
    echo "Site duplicated successfully."
}

# Main script starts here
echo "Found WordPress installations:"
list_wp_sites

echo "Enter the source site domain you want to duplicate:"
read -r source_site

echo "Enter the new site domain:"
read -r new_site_domain

echo "Enter the new database name:"
read -r new_db_name

echo "Enter the new database username:"
read -r new_db_user

echo "Enter the new database password:"
read -r new_db_pass

duplicate_site "$source_site" "$new_site_domain" "$new_db_name" "$new_db_user" "$new_db_pass"
