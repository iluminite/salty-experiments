#!py
#
# -*- coding: utf-8 -*-
#
# Copyright © 2014 Contributors
# See LICENSE for details
#

# generate formula for installing python packages with pip
#
import os

def _generate_pip_pkg_state(name, config):
    '''
    Provided a python package `name` and `config` dictionary, generate a
    `pip.installed` state in the form:

    .. code::

       {{ name }}-pip:
         pip.installed:
           - name: {{ name }}
           - require:
               - pkg: base-pkg
               - pip: pip
               - cmd: ppa-complete
               - file: reclass-nodes

    plus the long list of defaults (pip state has a lot of options)

    '''
    # define default arguments passed to pip.installed state
    _DEFAULTS = {
        'requirements': None,
        'timeout': 15,
        'user': 'root',
        'use_wheel': False,
        'no_use_wheel': False,
        'group': 'root',
        'mode': '750',
        'makedirs': True,
        'log': None,
        'proxy': None,
        'editable': False,
        'find_links': None,
        'index_url': None,
        'extra_index_url': None,
        'no_index': False,
        'mirrors': None,
        'build': None,
        'target': None,
        'download': None,
        'download_cache': None,
        'source': None,
        'upgrade': None,
        'force_reinstall': None,
        'ignore_installed': None,
        'exists_action': None,
        'no_deps': None,
        'no_install': None,
        'no_chown': None,
        'cwd': None,
        'activate': None,
        'pre_releases': None,
        'cert': None,
        'allow_all_external': None,
        'allow_external': None,
        'allow_unverified': None,
        'process_dependency_links': None,
        'bin_env': None,
        'env_vars': None,
        'use_vt': False,
        'install_options': None,
    }
    # build a new config dict for merging
    c = {}
    c.update(_DEFAULTS)
    # the 'packages:pip_defaults' pillar is optional
    try: c.update(__pillar__['packages']['pip_defaults'])
    except: pass
    # config comes from pillar, it's the pkg-specific config
    c.update(config)
    # unique state id for this pip packge
    pip_pkg_id = '{0}-pip'.format(name)
    # build the pip.installed formula
    states = {
        pip_pkg_id: {
            'pip.installed': [
                {'name': name},
                {'require': [
                    {'pkg': 'base-pkg'},
                    {'pip': 'pip'},
                    {'cmd': 'ppa-complete'},
                    {'file': 'reclass-nodes'},
                    ]
                },
            ]
        }
    }
    # shuffle our config dictionary into a list of dictionaries
    c = [{k:v} for k,v in c.iteritems()]
    # update the pip.installed state to include our list of config attributes
    states[pip_pkg_id]['pip.installed'].append(c)
    return states


def run():
    '''
    Pillar is expected in the form:

    .. code::

       pip_defaults:
         cwd: /tmp/
       pip:
         requests: {}
         django:
           activate: /var/python/my_app/bin/python


    This would generate formula similar to:

    .. code::

       requests-pip:
         pip.installed:
           - name: requests
           - cwd: /tmp/
           - defaults: ...
           - require:
               - pkg: base-pkg
               - pip: pip
               - cmd: ppa-complete
               - file: reclass-nodes
       django-pip:
         pip.installed:
           - name: django
           - cwd: /tmp/
           - activate: /var/python/my_app/bin/python
           - defaults: ...
           - require:
               - pkg: base-pkg
               - pip: pip
               - cmd: ppa-complete
               - file: reclass-nodes
    '''
    # pull pip package dictionary from  pillar - the list of pkg with config, hashed
    pip_packages = __pillar__['packages']['pip'] or {}
    states = {}
    # generate a pip.installed formula for each pip package specified in pillar
    for pkg, config in pip_packages.iteritems():
        states.update(_generate_pip_pkg_state(pkg, config))
    return states
