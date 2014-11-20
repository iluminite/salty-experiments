#!py
#
# -*- coding: utf-8 -*-
#
# Copyright © 2014 Contributors
# See LICENSE for details
#

# generate formula to create new users
def _generate_user_state(user, config):
    '''
    Provided a `user` and `config` dictionary, generate a `user.present` and a
    `group.present` formula for the user, in the form:

    .. code::

       {{ user }}-user:
         user.present:
           - name: {{ user }}
           - home: {{ c['home'] }}
               - ...
           - require:
               - group: {{ user }}-group

       {{ user }}-group:
         group.present:
           - name: {{ user }}
           - gid: {{ c['gid'] }}


    _DEFAULTS are:

    .. code::

       {
           'groups': [],
           'createhome': True,
           'gid_from_name': True,
           'uid': None,
           'gid': None,
           'system': False,
           'password': '*',
           'enforce_password': True,
           'shell': '/bin/nologin',
           'createhome': True,
           'home': '/nonexistent',
       }

    '''
    # define default arguments passed to user.present and group.present states
    _DEFAULTS = {
        'groups': [],
        'createhome': True,
        'gid_from_name': True,
        'uid': None,
        'gid': None,
        'system': False,
        'password': '*',
        'enforce_password': True,
        'shell': '/bin/nologin',
        'createhome': True,
        'home': '/nonexistent',
    }
    # build a new config dict for merging
    c = {}
    c.update(_DEFAULTS)
    # config comes from pillar
    c.update(config)
    # unique state ids for this user/group
    user_id = '{0}-user'.format(user)
    group_id = '{0}-group'.format(user)
    # build the user/group formula
    return {
        group_id: {
            'group.present': [
                {'name': user },
                {'gid': c['gid']},
            ]
        },
        user_id: {
            'user.present': [
                {'name': user },
                {'home ': c['home'] },
                {'gid_from_name': c['gid_from_name']},
                {'groups': c['groups']},
                {'system': c['system']},
                {'uid': c['uid']},
                {'gid': c['gid']},
                {'createhome': c['createhome']},
                {'password': c['password']},
                {'enforce_password': c['enforce_password']},
                {'shell': c['shell']},
                {'require': [
                    {'group': group_id}
                ]},
            ]
        }
    }


def run():
    '''
    Pillar is expected in the form:

    .. code::

       users:
         my_user: {}

    This will generate a set of formula with a `user.present` and `group.present`
    state for each user specified in pillar. The state definitions will look
    like:

    .. code::

       my_user-user:
         user.present:
           - name: my_user
           - defaults: ...
           - require:
               - group: my_user
       my_user-group:
         group.present:
           - name: my_user

    '''
    # the user dictionary with config for each user to create
    users = __pillar__['users'] or {}
    states = {}
    # generate a user.present and a group.present state for each user
    for user, config in users.iteritems():
        states.update(_generate_user_state(user, config))
    return states
