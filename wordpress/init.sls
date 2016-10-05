{% from "wordpress/map.jinja" import map with context %}

include:
  - wordpress.cli
{%- if salt['pillar.get']('wordpress:site_dependencies:include') %}
{%- for include_item in salt['pillar.get']('wordpress:site_dependencies:include') %}
  - {{ include_item }}
{%- endfor %}
{%- endif %}

{% for id, site in salt['pillar.get']('wordpress:sites', {}).items() %}
{{ map.docroot }}/{{ id }}:
  file.directory:
    - user: {{ map.www_user }}
    - group: {{ map.www_group }}
    - mode: 755
    - makedirs: True
{%- if salt['pillar.get']('wordpress:site_dependencies:require') %}
    - require:
{%- for require_item in salt['pillar.get']('wordpress:site_dependencies:require') %}
      - {{ require_item }}
{%- endfor %}
{%- endif %}

# This command tells wp-cli to download wordpress
download_wordpress_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}
  - name: >
      /usr/local/bin/wp core download
      --path="{{ map.docroot }}/{{ id }}/"
  - runas: {{ map.www_user }}
  - unless: test -f {{ map.docroot }}/{{ id }}/wp-config.php

# This command tells wp-cli to create our wp-config.php, DB info needs
# to be the same as above
configure_{{ id }}:
 cmd.run:
  - name: >
      /usr/local/bin/wp core config
      --dbname="{{ site.get('database') }}"
      --dbuser="{{ site.get('dbuser') }}"
      --dbpass="{{ site.get('dbpass') }}"
      --dbhost="{{ site.get('dbhost') }}"
      --path="{{ map.docroot }}/{{ id }}"
  - cwd: {{ map.docroot }}/{{ id }}
  - runas: {{ map.www_user }}
  - unless: test -f {{ map.docroot }}/{{ id }}/wp-config.php

# This command tells wp-cli to install wordpress
install_{{ id }}:
 cmd.run:
  - cwd: {{ map.docroot }}/{{ id }}
  - name: >
      /usr/local/bin/wp core install
      --url="{{ site.get('url') }}"
      --title="{{ site.get('title') }}"
      --admin_user="{{ site.get('username') }}"
      --admin_password="{{ site.get('password') }}"
      --admin_email="{{ site.get('email') }}"
      --path="{{ map.docroot }}/{{ id }}/"
  - runas: {{ map.www_user }}
  - unless: >
      /usr/local/bin/wp core is-installed
      --path="{{ map.docroot }}/{{ id }}"
{% endfor %}
