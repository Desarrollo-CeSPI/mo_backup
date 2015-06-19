module MoBackup
  module BaseBackup
    def self.included(klass)
      klass.actions :create, :remove
      klass.default_action :create

      klass.attribute :name, :kind_of => String, :name_attribute => true, :regex => /^[\w.]+/i
      klass.attribute :description, :kind_of => String
      klass.attribute :user, :kind_of => String, :default => 'root'
      klass.attribute :backup_directory, :kind_of => String, :default => 'Backup/models'
      klass.attribute :notifiers, :kind_of => Hash, :default => Hash.new
    end

    module Provider
      def save_backup(name)
        backups = (node['mo_backup']['backups'] || []).to_a
        backups << name
        node.set['mo_backup']['backups'] = backups.uniq
      end

      def remove_backup(name)
        backups = (node['mo_backup']['backups'] || []).to_a
        backups.delete name
        node.set['mo_backup']['backups'] = backups
      end

      def backup_directory
        ::File.join ::Dir.home(new_resource.user), new_resource.backup_directory
      end


      def create_backup_directory
        backup_directory_manage
      end

      def create_default_config_file
        me = self
        # Generate empty config.rb if it does not exist.
        file "backup config file #{new_resource.name}" do
          path lazy { ::File.join me.backup_directory,"..", "config.rb" }
          content <<-CNF
# Backup v4.x Configuration
Utilities.configure do
  send_nsca "#{node['mo_backup']['send_nsca']}"
end
          CNF
          owner new_resource.user
          mode '0755'
          action :create
        end
      end

      def remove
        delete_cron
      end


      def backup_directory_manage(create = true)
        me = self
        directory "backup model directory for #{new_resource.name}" do
          path lazy { me.backup_directory }
          owner new_resource.user
          action create ? :create : :delete
          recursive true
        end
      end

      def backup_command(model)
        "sleep ${RANDOM:0:2} ; /bin/bash -lc \"backup perform -q --no-logfile --syslog --trigger #{model}\" 2>&1 |  grep -v 'stdin: is not a tty'"
      end

    end
  end
end

