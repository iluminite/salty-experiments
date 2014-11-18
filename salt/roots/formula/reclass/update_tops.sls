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

{#- filesystem paths for reclass #}
{%- set paths = salt['pillar.get']('reclass:paths') %}
{#- the filesystem path to reclass node definitions #}
{%- set nodes_path = paths['nodes'] %}
{#- the full node uri parameter to pass to reclass #}
{%- set nuri = '--nodes-uri ' + nodes_path + ' ' %}
{#- the filesystem path where reclass should look for classes #}
{%- set classes_path = paths['classes'] %}
{#- the full class url parameter to pass to reclass #}
{%- set curi = '--classes-uri ' + classes_path + ' ' %}
{#- the filesystem path to the top.sls we want to write to #}
{%- set tops_path = paths['tops'] %}
{#- the complete command to update top.sls with a dump from reclass for this node #}
{%- set update_tops_cmd = 'reclass-salt --top ' + nuri + curi + ' > ' + tops_path %}

include:
  - reclass.base


reclass-update_tops:
  cmd.run:
    - name: {{ update_tops_cmd }}
    - require:
        - file: reclass-nodes
