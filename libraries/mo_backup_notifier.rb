module MoBackup
  module Notifier

    def self.generate_config(notifiers_hash)
      Mash.new(notifiers_hash).map do |notifier_name, options|
        raise "Notifier type is not specified for #{notifier_name}" unless options['type']
        klass = options['type'].capitalize
        MoBackup::Notifier.const_get(klass).new(options).to_s
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

  end
end
