module MoBackup
  module Database
    def self.generate_config(databases_hash)
      Mash.new(databases_hash).map do |unique_name, options|
        raise "Database type is not specified for #{unique_name}" unless options['type']
        klass = options['type'].capitalize
        MoBackup::Database.const_get(klass).new(options.merge('unique_name' => unique_name)).to_s
      end.join "\n"
    end

    class Default < MoBackup::Component::Default
      alias :database_id :component_id
      # Alias for class method
      class << self
        alias :database_id :component_id
      end


      def to_s
        str_options = options_except("component_id", "unique_name").map {|k,v| "    db.#{k} = #{v}"}.join "\n"
        <<-SCRIPT 
database #{database_id}, #{options['unique_name']} do |db|
#{str_options}
  end
      SCRIPT
      end
    end

    class Mongodb < Default
      option "unique_name", :symbol
      option "name", :string
      option "username", :string
      option "password", :string
      option "host", :string, "localhost"
      option "port", :number, 27017
      option "ipv6", :boolean, false
      option "lock", :boolean, false
      option "oplog", :boolean, false
      option "only_collections", :array
      option "additional_options", :array
      database_id "MongoDB"
    end

    class Mysql < Default
      option "unique_name", :symbol
      option "name", :string
      option "username", :string
      option "password", :string
      option "host", :string, "localhost"
      option "port", :number, 3306
      option "socket", :string
      option "sudo_user", :string
      option "skip_tables", :string
      option "only_tables", :string
      option "additional_options", :array
      option "prepare_backup", :boolean, true
      database_id "MySQL"
    end

    class Redis < Default
      option "unique_name", :symbol
      option "mode", :symbol, "copy"
      option "host", :string, "localhost"
      option "port", :number, 6379
      option "socket", :string
      option "password", :string
      option "rdb_path", :string
      option "additional_options", :array
      option "invoke_save", :boolean, false
    end

  end
end

