include ::MoBackup::BaseBackup
attribute :directories, :kind_of => [Array, String], :default => []
attribute :exclude, :kind_of => [Array, String], :default => []
attribute :syncers, :kind_of => Hash, :default => Hash.new

attribute :every_minutes, :kind_of => [Integer,FalseClass], :default => 30
attribute :every_hours, :kind_of => [Integer,FalseClass], :default => false
