use_inline_resources

include ::MoBackup::BaseBackup::Provider

def whyrun_supported?
  true
end

action :create do
  converge_by("Create new sync model #{@new_resource}") do

    create_backup_directory

    create_default_config_file

    name = "sync-#{new_resource.name}"

    create_model_template name

    cron_backup true, name
  end
end

action :remove do
  converge_by("Removes a sync model #{@new_resource}") do
    remove
  end
end

def delete_cron
    name = "sync-#{new_resource.name}"
    cron_backup false, name
end

private
def create_model_template(name)

  syncer_options = Mash.new

  new_resource.syncers.each do |k,options|
    syncer_options[k] = Mash.new(options.is_a?(Hash) ? options : options.to_hash)
    syncer_options[k].merge!(:directory => new_resource.directories, :exclude => new_resource.exclude, :path => ::File.join(options['path'],new_resource.prefix_path))
  end

  template "backup sync #{name}" do
    path lazy {::File.join(backup_directory,"#{name}.rb")}
    owner new_resource.user
    source "model_sync.rb.erb"
    cookbook "mo_backup"
    variables(:name => name,
              :description => new_resource.description,
              :syncers_config => ::MoBackup::Syncer.generate_config(syncer_options),
              :notifiers_config => ::MoBackup::Notifier.generate_config(new_resource.notifiers),
              )
  end
end

def cron_backup(create, name)
  me = self
  if new_resource.every_minutes
    cron "sync #{new_resource.name} every #{new_resource.every_minutes} minutes" do
      minute  "*/#{new_resource.every_minutes}"
      hour    '*'
      day     '*'
      month   '*'
      weekday '*'
      user    new_resource.user
      command me.backup_command name
      action  create ? :create : :delete
    end
  end
  if new_resource.every_hours
    cron "sync #{new_resource.name} every #{new_resource.every_hours} hours" do
      minute  (1..59).to_a.sample
      hour    "*/#{new_resource.every_hours}"
      day     '*'
      month   '*'
      weekday '*'
      user    new_resource.user
      command me.backup_command name
      action  create ? :create : :delete
    end
  end
end
