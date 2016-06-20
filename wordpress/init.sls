{% from "wordpress/map.jinja" import map with context %}

include:
  - wordpress.cli

{% for id, site in salt['pillar.get']('wordpress:sites', {}).items() %}
{{ map.docroot }}/{{ id }}:
  file.directory:
    - user: {{ map.www_user }}
    - group: {{ map.www_group }}
    - mode: 755
    - makedirs: True

<<<<<<< HEAD
get-wordpress:
  cmd.run:
    - name: 'curl -O -L http://wordpress.org/latest.tar.gz && tar xvzf latest.tar.gz && /bin/rm latest.tar.gz'
    - cwd: /var/www/html/
    - unless: test -d /var/www/html/wordpress
    - require:
      - pkg: httpd-packages
    - require_in:
      - file: /var/www/html/wordpress/wp-config.php
  
wordpress-keys-file:
  cmd.run:
    - name: /usr/bin/curl -s -o /var/www/html/wordpress/wp-keys.php https://api.wordpress.org/secret-key/1.1/salt/ && /bin/sed -i "1i\\<?php" /var/www/html/wordpress/wp-keys.php && chown -R apache:apache /var/www/html/wordpress
    - unless: test -e /var/www/html/wordpress/wp-keys.php
    - require_in:
      - file: /var/www/html/wordpress/wp-config.php
  
wordpress-config:
  file.managed:
    - name: /var/www/html/wordpress/wp-config.php
    - source: salt://mysql/files/wp-config.php
    - mode: 0644
    - user: apache
    - group: apache
    - template: jinja
    - context:
      username: {{ pillar['wordpress']['wp-username'] }}
      database: {{ pillar['wordpress']['wp-database'] }}
      password: {{ pillar['wordpress']['wp-passwords']['wordpress'] }}
    - require:
      - cmd: get-wordpress
=======
# This command tells wp-cli to download wordpress
download_wordpress_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}
  - name: '/usr/local/bin/wp core download --path="{{ map.docroot }}/{{ id }}/"'
  - user: {{ map.www_user }}
  - unless: test -f {{ map.docroot }}/{{ id }}/wp-config.php
>>>>>>> 41e6539d92c0b1652ee7d533d9b16359630b7a2a

# This command tells wp-cli to create our wp-config.php, DB info needs to be the same as above
configure_{{ id }}:
 cmd.run:
  - name: '/usr/local/bin/wp core config --dbname="{{ site.get('database') }}" --dbuser="{{ site.get('dbuser') }}" --dbpass="{{ site.get('dbpass') }}" --dbhost="{{ site.get('dbhost') }}" --path="{{ map.docroot }}/{{ id }}"'
  - cwd: {{ map.docroot }}/{{ id }}
  - user: {{ map.www_user }}
  - unless: test -f {{ map.docroot }}/{{ id }}/wp-config.php  

# This command tells wp-cli to install wordpress
install_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}
  - name: '/usr/local/bin/wp core install --url="{{ site.get('url') }}" --title="{{ site.get('title') }}" --admin_user="{{ site.get('username') }}" --admin_password="{{ site.get('password') }}" --admin_email="{{ site.get('email') }}" --path="{{ map.docroot }}/{{ id }}/"'
  - user: {{ map.www_user }}
  - unless: /usr/local/bin/wp core is-installed --path="{{ map.docroot }}/{{ id }}"

{% endfor %}
