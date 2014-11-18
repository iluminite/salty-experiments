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


{%- set ppa_list = salt['pillar.get']('packages:ppa', []) %}

{#- iterate over the list of ppa to setup for apt #}
{%- for ppa in ppa_list %}
ppa-{{ ppa }}:
  pkgrepo.managed:
    - ppa: {{ ppa }}
    - require:
        - pkg: ppa-salt-dependency
    - require_in:
        - cmd: ppa-complete
{%- endfor %}


{#- use this to ensure all PPA repos are in place and successful #}
{#- other formula can reference this with a require or watch #}
ppa-complete:
  cmd.run:
    - name: echo "all ppa in place for apt!"

