reclass:
  git:
    url: https://github.com/madduck/reclass.git
    rev: ff1342cbbb6f5c302abcf0f5cdfab0c38f6432b6
    path: /tmp/reclass
    user: root
  paths:
    base: /etc/reclass
    nodes: /etc/reclass/nodes
    classes: /etc/salt/roots/formula/manifests
    formula: /etc/salt/roots/formula
    tops: /etc/salt/roots/formula/top.sls
  localhost:
    classes:
      - salt.masterless-minion
      - reclass
    parameters:
      hello: world
