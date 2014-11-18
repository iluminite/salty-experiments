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

{#- set the service as either running or disabled #}
{%- set status = salt['pillar.get']('salt:minion:service:status') %}
{#- boolean - if enabled, the service starts on boot #}
{%- set enabled = salt['pillar.get']('salt:minion:service:enabled') %}
{#- system_fqdn pulled from pillar, with fallback to the hostname (from salt) #}
{%- set system_fqdn = salt['pillar.get']('system_fqdn', grains['host']) %}
{#- the id (name) of the minion, fallback to system_fqdn if not set #}
{%- set mid = salt['pillar.get']('salt:minion:id', system_fqdn) %}
{#- the base path for salt configuration is hardcoded for now #}
{%- set config_path = '/etc/salt' %}

salt-minion:
  pkg.installed:
    - name: salt-minion
  file.managed:
    - name: {{ config_path }}/minion
    - template: jinja
    - source: salt://salt/files/etc/salt/minion
  service:
    - {{ status }}
    - enable: {{ enabled }}
    - watch:
        - pkg: salt-minion
        - file: salt-minion

salt-minion-id:
  file.managed:
    - name: {{ config_path }}/minion_id
    - contents: {{ mid }}
