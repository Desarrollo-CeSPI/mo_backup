default[:mo_backup][:ruby_version] = "2.1.4"
default[:mo_backup][:send_nsca] = '/usr/sbin/send_nsca'
default[:mo_backup][:send_nsca_config] = '/etc/nagios/send_nsca.cfg'
default[:mo_backup][:backups_disabled] = false
default[:mo_backup][:restore_script] = "/usr/local/sbin/restore-backup"
