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

# install reclass from source (git)
#
# this state current expects the following to be in place:
#   * the git and python packages are installed
#
# additional instructions are available:
# http://reclass.pantsfullofunix.net/install.html
# uninstall with the following:
# rm -r /usr/local/lib/python*/dist-packages/reclass* /usr/local/bin/reclass*

{#- URL pointing to the Reclass git repository #}
{%- set url = salt['pillar.get']('reclass:git:url') %}
{#- the git revision to checkout (and install) #}
{%- set rev = salt['pillar.get']('reclass:git:rev') %}
{#- the path to checkout the reclass git repo to, and to install from #}
{%- set path = salt['pillar.get']('reclass:git:path') %}
{#- the user to checkout git and install reclass as #}
{%- set user = salt['pillar.get']('reclass:git:user') %}


reclass:
  git.latest:
    - name: {{ url }}
    - rev: {{ rev }}
    - target: {{ path }}
    - user: {{ user }}
    - force: True
  # by using cmd.wait, we run when the reclass git repo changes
  # with install -f, we enforce an update (if already installed)
  # this will _only_ run when the repo changes
  cmd.wait:
    - name: python setup.py install -f
    - cwd: {{ path }}
    - user: {{ user }}
    - watch:
        - git: reclass
    - require:
        - pkg: python-setuptools

# ensure reclass is installed - run if there is no reclass binary present in
# $PATH even if there are no changes to the git repo
reclass-install:
  cmd.run:
    - name: python setup.py install -f
    - cwd: {{ path }}
    - user: {{ user }}
    - unless: test -f /usr/local/bin/reclass
    - require:
        - git: reclass
        - pkg: python-setuptools
