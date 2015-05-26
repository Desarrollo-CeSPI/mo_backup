include ::MoBackup::BaseBackup
attribute :use_sudo, :kind_of => [TrueClass, FalseClass], :default => false
attribute :root, :kind_of => [String, NilClass], :default => nil
attribute :archives, :kind_of => [Array, String], :default => []
attribute :exclude, :kind_of => [Array, String], :default => []
attribute :compress, :kind_of => [TrueClass, FalseClass], :default => true
attribute :storages, :kind_of => Hash, :default => Hash.new
attribute :databases, :kind_of => Hash, :default => Hash.new
attribute :daily_keeps, :kind_of => Integer, :default => 30
attribute :weekly_keeps, :kind_of => Integer, :default => 20
attribute :monthly_keeps, :kind_of => Integer, :default => 24
attribute :start_hour, :kind_of => Integer, :default => 1, :equal_to => 0..23
attribute :end_hour, :kind_of => Integer, :default => 7, :equal_to => 0..23
attribute :week_day, :kind_of => Integer, :default => 0, :equal_to => 0..7
attribute :month_day, :kind_of => Integer, :default => 1, :equal_to => 1..28
