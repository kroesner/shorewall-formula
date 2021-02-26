{% from "shorewall/map.jinja" import map with context %}

{% set ipv = salt['pillar.get']('shorewall:ipv', [4]) %}

{% for v in ipv %}
  {% set pkg = map['pkg_v{0}'.format(v)] %}
  {% set name = 'shorewall_v{0}'.format(v) %}
  {% set config_path = map['config_path_v{0}'.format(v)] %}
  {% set service = map['service_v{0}'.format(v)] %}
  {% set installed_pkg_version = salt['pkg.version'](pkg)|string() %}
  {% if installed_pkg_version != '' %}
  {%   set pkg_version = installed_pkg_version[0:3] %}
  {% else %}
  {%   set pkg_version = (salt['pkg.latest_version'](pkg)|string())[0:3] %}
  {% endif %}

# Install required packages
shorewall_v{{ v }}:
  pkg:
    - installed
    - name: {{ pkg }}
  service.running:
    - name: {{ service }}
    - enable: True


# Create config files
  {% for config in map.config_files %}
shorewall_v{{ v }}_config_{{ config }}:
  file.managed:
    - name: "{{ config_path }}/{{ config }}"
    - source: salt://shorewall/files/{{ config }}.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: {{ name }}
    - watch_in:
      - service: {{ name }}
    - context:
        ipv: {{ v }}
        pkg_version: {{ pkg_version }}

  {% endfor %}
{% endfor %}

shorewall_etcdefault:
  file.managed:
    - name: {{ map.etcdefault_file }}
    - source: salt://shorewall/files/etcdefault.jinja  
    - template: jinja  
    - watch_in:
      - service: shorewall_v4

{%- if 6 in salt['pillar.get']('shorewall:ipv', [4]) %}
shorewall6_etcdefault:
  file.managed:
    - name: {{ map.etcdefault6_file }}
    - source: salt://shorewall/files/etcdefault.jinja
    - template: jinja
    - watch_in:
      - service: shorewall_v6
{%- endif %}

shorewall_conf:
  file.managed:
    - name: {{ map.shorewallconf_file }}
    - source: salt://shorewall/files/shorewallconf.jinja
    - template: jinja  
    - watch_in:
      - service: shorewall_v4

{%- if 6 in salt['pillar.get']('shorewall:ipv', [4]) %}
shorewall6_conf:
  file.managed:
    - name: {{ map.shorewallconf6_file }}
    - source: salt://shorewall/files/shorewallconf.jinja
    - template: jinja  
    - watch_in:
      - service: shorewall_v6
{%- endif %}