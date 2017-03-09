include:
  - .deps

etckeeper:
  pkg.installed:
    - require:
      - pkg: etckeeper_deps

/etc/etckeeper:
  file.directory:
    - mode: 0755
    - user: root
    - group: root
    - require:
      - pkg: etckeeper

/etc/etckeeper/etckeeper.conf:
  file.managed:
    - source: salt://etckeeper/files/etckeeper.conf.jinja
    - template: jinja
    - mode: 0644
    - makedirs: True
    - user: root
    - group: root
    - require_in:
      - file: /etc/etckeeper
    - require:
      - pkg: etckeeper

etckeeper_initial_commit:
  cmd.run:
    - cwd: /etc
    - name: "/usr/bin/etckeeper init && SUDO_USER="root" /usr/bin/etckeeper commit 'Initial commit'"
    - require:
      - pkg: etckeeper
      - file: /etc/etckeeper/etckeeper.conf
    - unless: test -d /etc/.git

etckeeper_commit_at_start:
  cmd.run:
    - order: 0
    - cwd: /etc
    - name: 'SUDO_USER="root" /usr/bin/etckeeper commit "Changes found prior to start of salt run #salt-start"'
    - onlyif: 'test -d /etc/.git && test -n "$(git status --porcelain)"'

etckeeper_commit_at_end:
  cmd.run:
    - order: last
    - cwd: /etc
    - name: 'SUDO_USER="root" /usr/bin/etckeeper commit "Changes made during salt run #salt-end"'
    - onlyif: 'test -d /etc/.git && test -n "$(git status --porcelain)"'
