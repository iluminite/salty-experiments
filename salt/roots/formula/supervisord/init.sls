{#-
 # Copyright (C) 2014 the Institute for Institutional Innovation by Data
 # Driven Design Inc.
 #
 # Permission is hereby granted, free of charge, to any person obtaining
 # a copy of this software and associated documentation files (the
 # "Software"), to deal in the Software without restriction, including
 # without limitation the rights to use, copy, modify, merge, publish,
 # distribute, sublicense, and/or sell copies of the Software, and to
 # permit persons to whom the Software is furnished to do so, subject to
 # the following conditions:
 #
 # The above copyright notice and this permission notice shall be
 # included in all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 # NONINFRINGEMENT. IN NO EVENT SHALL THE INSTITUTE FOR INSTITUTIONAL
 # INNOVATION BY DATA DRIVEN DESIGN INC. BE LIABLE FOR ANY CLAIM,
 # DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
 # OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 # OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 #
 # Except as contained in this notice, the names of the Institute for
 # Institutional Innovation by Data Driven Design Inc. shall not be used in
 # advertising or otherwise to promote the sale, use or other dealings
 # in this Software without prior written authorization from the
 # Institute for Institutional Innovation by Data Driven Design Inc.
 #}

{#- this name is used all over the place, within the formula #}
{%- set name = 'supervisord' %}
{#- retrieve the formula's config (pillar) for this service #}
{%- set conf = salt['pillar.get'](name) %}
{#- retrieve user config for the service #}
{%- set user = conf['user'] %}
{#- retrieve service config #}
{%- set service = conf['service'] %}
{#- retrieve config details for the service's config #}
{%- set config_file = conf['config'] %}


supervisord:
  pip.installed:
    - names:
        - supervisor


{#- user/group definitions #}
{%- if user %}
{{ name }}-user:
  group.present:
    - name: {{ user['group'] }}
    - gid: {{ user['gid'] }}
  user.present:
    - name: {{ user['username'] }}
    - uid: {{ user['uid'] }}
    - gid: {{ user['gid'] }}
    - home: {{ user['home'] }}
    - shell: {{ user['shell'] }}
    - require:
        - group: {{ name }}
{%- endif %}


{#- setup the service, if needed #}
{%- if service %}
{{name}}-service:
  file.managed:
    - name: /etc/init/supervisord.conf
    - source: salt://supervisord/files/upstart.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - require:
        - user: {{ name }}-user
        - group: {{ name }}-user
  service:
    - {{ service['status'] }}
    - name: {{ name }}
    - enable: {{ service['enabled'] }}
    - require:
        - user: {{ name }}-user
    - watch:
        - file: {{ name }}-config
        - file: {{ name }}-service
{%- endif %}


{#- config for the service #}
{{ name }}-config:
  file.managed:
    - name: {{ config_file['path'] }}
    - source: salt://supervisord/files/config.jinja
    - template: jinja
    - user: {{ user['username'] }}
    - group: {{ user['group'] }}
    - mode: 640
    - require:
        - user: {{ name }}-user
        - group: {{ name }}-user


{{ name }}-logs:
  file.directory:
    - name: /var/log/supervisord
    - user: {{ user['username'] }}
    - group: {{ user['group'] }}
    - mode: 750

