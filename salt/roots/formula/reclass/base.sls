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

{#- this is for reclass nodes/$host.yml #}
{%- set classes = salt['pillar.get']('reclass:localhost:classes', []) %}
{#- this is for reclass nodes/$host.yml #}
{%- set parameters = salt['pillar.get']('reclass:localhost:parameters', {}) %}
{#- filesystem paths for reclass #}
{%- set paths = salt['pillar.get']('reclass:paths') %}


# this symlink will let reclass function from the shell, outside salt, because
# reclass will see /etc/reclass/nodes even though it is /etc/salt/states/nodes
# this is to keep reclass happy
reclass-base_dir:
  file.exists:
    # note the lack of a trailing slash on the symlink name is intentional
    - name: /etc/reclass
#   # point the symlink at salt's file_roots, this ought to be dynamic (looked up)
#   - target: {{ paths['base'] }}


# to be super-explicit, we have reclass create a config for itself. this lets us
# more easily run reclass from the shell, and otherwise separate from salt.
reclass-reclass_config:
  file.managed:
    - name: {{ paths['base'] }}/reclass-config.yml
    - contents: |
        storage_type: yaml_fs
        pretty_print: True
        output: yaml
        inventory_base_uri: {{ paths['base'] }}
        nodes_uri: {{ paths['nodes'] }}
        classes_uri: {{ paths['classes'] }}
    - require:
        - file: reclass-base_dir


# this is the core link between reclass and salt, where to find the inventory
# and instructions to use ext_pillar.
# we'll keep it really simple for now, as the details here could get really
# complicated. funny enough, this is easier to sort out once reclass is in use.
reclass-salt_config:
  file.managed:
    - name: /etc/salt/minion.d/reclass
    - contents: |
        reclass: &reclass
          # the only currently supported
          storage_type: yaml_fs
          # reclass will expect to find a classes and nodes directory at this path
          inventory_base_uri: {{ paths['base'] }}
          classes_uri: {{ paths['classes'] }}
          nodes_uri: {{ paths['nodes'] }}

        # at the moment, master_tops is not available to the salt-minion :*
        #master_tops:
        #  reclass: *reclass

        ext_pillar:
          - reclass: *reclass
    - require:
        - file: reclass-reclass_config


# reclass associates classes with a node through a .yml associated with the host
# define a node map for localhost, but do it dynamically, based on a key from pillar
reclass-nodes:
  file.managed:
    - name: {{ paths['nodes'] }}/{{ salt['grains.get']('id') }}.yml
    - contents: |
        classes: {% if classes %}{% for class in classes %}
          - {{ class }}
          {% endfor %}{% endif %}
        {%- if parameters %}
        parameters: {% for k, v  in parameters.items() %}
          {{ k }}: {{ v }}
          {% endfor %}
        {% endif %}
    - require:
        - file: reclass-salt_config
