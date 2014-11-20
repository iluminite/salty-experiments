#!py
#
# -*- coding: utf-8 -*-
#
# Copyright © 2014 Contributors
# See LICENSE for details
#
import os

def _generate_service_state(name, config):
    '''
    Provided a service `name` and `config` dictionary, generate an appropriate
    `service.{running,dead}` state in the form:

    .. code::

       {{ name }}-service:
         service.{{ c['status'] }}:
           - name: {{ name }}
           - enable: {{ c['enable'] }}
           - reload: {{ c['reload'] }}

    `_DEFAULTS` looks like:

    .. code::

       {
           'status': 'dead',
           'enable': False,
           'reload': False,
       }


    '''
    # define default arguments passed to service state
    _DEFAULTS = {
        'status': 'dead',
        'enable': False,
        'reload': False,
    }
    # build a new config dict for merging
    c = {}
    c.update(_DEFAULTS)
    # config comes from pillar
    c.update(config)
    # unique state id for this service
    service_id = '{0}-service'.format(name)
    # build the service.{dead,running} formula
    states = {
        service_id: {
            'service': [ c['status'],
                {'name': name},
                {'enable': c['enable']},
            ]
        }
    }

    # reload is only applicable if the service status is running
    if c['status'] == 'running':
        states[service_id]['service'].append({'reload': c['reload']})
    return states


def run():
    '''
    Pillar is expected in the form:

    .. code::

       services:
	 ssh:
	   status: running
	   enable: True
	   reload: False
         salt-minion:
	   status: dead
	   enable: False

    This will generate a set for formula in the form:

    .. code::

       ssh-service:
         service.running:
	   - name: ssh
	   - enable: True
	   - reload: False
       salt-minion-service:
         service.dead:
           - name: salt-minion
           - enable: False

    '''
    # pull service dictionary from  pillar - the config for each service, hashed
    services = __pillar__['services'] or {}
    states = {}
    # generate a service.{dead,running} formula for each service in pillar
    for name, config in services.iteritems():
        states.update(_generate_service_state(name, config))
    return states
