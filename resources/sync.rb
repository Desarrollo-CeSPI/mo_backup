include ::MoBackup::BaseBackup
attribute :prefix_path, :kind_of => String, :default => ""
attribute :directories, :kind_of => [Array, String], :default => []
attribute :exclude, :kind_of => [Array, String], :default => []
attribute :syncers, :kind_of => Hash, :default => Hash.new

attribute :every_minutes, :kind_of => [Integer,FalseClass], :default => false
attribute :every_hours, :kind_of => [Integer,FalseClass], :default => false
