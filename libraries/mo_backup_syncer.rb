module MoBackup
  module Syncer

    def self.generate_config(storages_hash)
      Mash.new(storages_hash).map do |syncer_name, options|
        raise "Syncer type is not specified for #{syncer_name}" unless options['type']
        klass = options['type'].capitalize
        MoBackup::Syncer.const_get(klass).new(options).to_s
      end.join '\n'
    end

    class Default < MoBackup::Component::Default

      alias :syncer_id :component_id
      class << self
        alias :syncer_id :component_id
      end

      attr_reader :directory

      def to_s
        str_options = options_except("component_id","directory","exclude").map {|k,v| "    server.#{k} = #{v}"}.join "\n"
        str_dirs = Array(options['directory']).map {|path| "      directory.add '#{path}'"}.join "\n"
        str_dirs += "\n" + Array(options['exclude']).map {|path| "      directory.exclude '#{path}'"}.join("\n")
        <<-SCRIPT
sync_with #{syncer_id} do |server|
#{str_options}
    server.directories do |directory|
#{str_dirs}
    end
  end
        SCRIPT
      end

    end

    class Rsync < Default
      option "path", :string, "backups"
      option "mode", :symbol, "ssh"
      option "host", :string
      option "port", :integer, 22
      option "mirror", :boolean, true
      option "compress", :boolean, true
      option "directory", :array, []
      option "exclude", :array, []
      option "rsync_user", :string, 'backup'
      option "rsync_password", :string
      option "ssh_user", :string, 'backup'
      option "additional_ssh_options", :string
      option "additional_rsync_options", :string
      syncer_id "RSync::Push"
    end

  end
end
