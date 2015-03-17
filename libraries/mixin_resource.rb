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
          content "# Backup v4.x Configuration"
          owner new_resource.user
          mode '0755'
          action :create_if_missing
        end
      end

      def remove
        delete_backup_data
        delete_cron
      end

      def delete_backup_data
        backup_directory_manage false
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
        "/bin/bash -lc \"backup perform -q --trigger #{model}\" >/dev/null 2>&1"
      end

    end
  end
end

