module MoBackup
  module Notifier

    def self.generate_config(notifiers_hash, extra_options={})
      Mash.new(notifiers_hash).map do |notifier_name, options|
        raise "Notifier type is not specified for #{notifier_name}" unless options['type']
        klass = options['type'].capitalize
        MoBackup::Notifier.const_get(klass).new(options.to_hash.merge(extra_options)).to_s
      end.join "\n"
    end

    class Default < MoBackup::Component::Default

      alias :notifier_id :component_id
      class << self
        alias :notifier_id :component_id
      end

      def to_s
        str_options = options_except("component_id").map {|k,v| "    notifier.#{k} = #{v}"}.join "\n"
        <<-SCRIPT
notify_by #{notifier_id} do |notifier|
#{str_options}
  end
        SCRIPT
      end

    end

    class Mail < Default
      option "on_success", :boolean, false
      option "on_warning", :boolean, true
      option "on_failure", :boolean, true

      option "from", :string
      option "to", :string
      option "address", :string
      option "port", :integer, 25
      option "domain", :string
      option "user_name", :string
      option "password", :string
      option "authentication", :string, 'plain'
      option "encryption", :symbol, :none
      notifier_id "Mail"
    end

    class Nagios < Default
      option "on_success", :boolean, true
      option "on_warning", :boolean, true
      option "on_failure", :boolean, true

      option "nagios_host", :string
      option "nagios_port", :integer, 5667
      option "service_name", :string
      option "service_host", :string
      notifier_id "Nagios"

      def initialize(options)
        host = options.delete('node')
        options.merge! 'service_host' => host if host
        resource_name = options.delete('resource_name')
        options.merge! 'service_name' => "mo_backup_#{resource_name}" if resource_name
        super
      end
    end

  end
end
