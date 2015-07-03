include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

# needed for Nagios notifications used with nsca
package 'nsca'
directory ::File.dirname(node[:mo_backup][:send_nsca_config]) do
  not_if "test -d #{::File.dirname(node[:mo_backup][:send_nsca_config])}"
end

file node[:mo_backup][:send_nsca_config]
# End of nsca requirements


ruby_version = node[:mo_backup][:ruby_version]

rbenv_ruby ruby_version do
  global true
end

rbenv_gem "backup" do
  ruby_version ruby_version
end

cookbook_file node['mo_backup']['restore_script'] do
  mode "0700"
  source 'restore-backup'
end
