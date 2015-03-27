module MoBackup
  module Storage

    def self.generate_config(default_keep, storages_hash)
      Mash.new(storages_hash).map do |storage_name, options|
        raise "Storage type is not specified for #{storage_name}" unless options['type']
        klass = options['type'].capitalize
        options['keep'] ||= default_keep # Set default keep
        MoBackup::Storage.const_get(klass).new(options).to_s
      end.join "\n"
    end

    class Default < MoBackup::Component::Default

      alias :storage_id :component_id

      # Alias for class method
      class << self
        alias :storage_id :component_id
      end

      def to_s
        str_options = options_except("component_id").map {|k,v| "    server.#{k} = #{v}"}.join "\n"
        <<-SCRIPT
store_with #{storage_id} do |server|
#{str_options}
  end
        SCRIPT
      end

    end

    class Dropbox < Default
      option "api_key", :string
      option "api_secret", :string
      option "cache_path", :string, ".cache"
      option "access_type", :symbol, :app_folder
      option "path", :string, "/backups"
      option "keep", :number, 5
      option "chunk_size", :number
      option "max_retries", :number
      option "retry_waitsec", :number
      storage_id "Dropbox"
    end

    class S3 < Default
      option "access_key_id", :string
      option "secret_access_key", :string
      option "region", :string
      option "bucket", :string
      option "path", :string, "/backups"
      option "keep", :number, 5
      storage_id "S3"
    end

    class Scp < Default
      option "username", :string, 'user'
      option "password", :string, 'pass'
      option "ip", :string
      option "port", :number, 22
      option "path", :string, "backups"
      option "keep", :number, 5
      storage_id "SCP"
    end

    class Sftp < Default
      option "username", :string, 'user'
      option "password", :string, 'pass'
      option "ip", :string
      option "port", :number, 22
      option "path", :string, "backups"
      option "keep", :number, 5
      storage_id "SFTP"
    end

  end
end
