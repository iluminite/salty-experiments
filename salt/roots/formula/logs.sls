#!py
#
# -*- coding: utf-8 -*-
#
# Copyright © 2014 Contributors
# See LICENSE for details
#
import os

def _generate_log_path_states(name, config):
    '''
    Provided an entry `name` and `config` dictionary, generate a `file.directory`
    state in the form:

    .. code::

       {{ name }}-var-log:
         file.directory:
           - name: /var/log/{{ name }}
           - mode: {{ c['mode'] }}
           - user: {{ c['user'] }}
           - group: {{ c['group'] }}
           - makedirs: {{ c['makedirs'] }}

    `_DEFAULTS` looks like:

    .. code::

       {
           'user': 'root',
           'group': 'root',
           'mode': '750',
           'makedirs': True,
       }

    '''
    # define default arguments passed to service state
    _DEFAULTS = {
        'user': 'root',
        'group': 'root',
        'mode': '750',
        'makedirs': True,
    }
    # build a new config dict for merging
    c = {}
    c.update(_DEFAULTS)
    # config comes from pillar
    c.update(config)
    # unique state id for this service
    log_path_id = '{0}-var-log'.format(name)
    # build the file.directory formula
    log_path = os.path.join('/', 'var', 'log', name)
    return {
        log_path_id: {
            'file.directory': [
                {'name': log_path},
                {'user': c['user']},
                {'group': c['group']},
                {'mode': c['mode']},
                {'makedirs': c['makedirs']},
            ]
        }
    }


def run():
    '''
    Pillar is expected in the form:

      var_log:
        my_app:
          user: my_app
          group: root
          mode: 750
          makedirs: True/False


    This will generate a set of formula with one state for each entry, in this
    case `my_app`. The state definition will look like:

      my_app-var-log:
        file.directory:
          - name: /var/log/my_app
          - user: my_app
          - group: root
          - mode: 750
          - makedirs: True


    '''
    # the config for each log entry, hashed
    var_log = __pillar__['var_log'] or {}
    states = {}
    # generate a file.directory formula for each entry in pillar
    for entry, config in var_log.iteritems():
        states.update(_generate_log_path_states(entry, config))
    return states
