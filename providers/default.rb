use_inline_resources

include ::MoBackup::BaseBackup::Provider

def whyrun_supported?
  true
end

action :create do
  converge_by("Create new backup model #{@new_resource}") do

    create_backup_directory

    create_default_config_file

    backup_periods.each do |period_name, period_options|

      name = "backup-#{new_resource.name}-#{period_name}"

      create_model_template name, period_options[:keep]

      cron_backup true, name, period_name, period_options

    end

  end
end

action :remove do
  converge_by("Removes a backup model #{@new_resource}") do
    backup_periods.each do |period_name, period_options|
      name = "backup-#{new_resource.name}-#{period_name}"
      file ::File.join(backup_directory,"#{name}.rb") do
        action :delete
      end
    end
    remove
  end
end

def delete_cron
    backup_periods.each do |period_name, period_options|
      name = "backup-#{new_resource.name}-#{period_name}"
      cron_backup false, name, period_name, period_options
    end
end

private
def create_model_template(name, default_keep)
  template "backup model #{name}" do
    path lazy {::File.join(backup_directory,"#{name}.rb")}
    owner new_resource.user
    source "model.rb.erb"
    cookbook "mo_backup"
    variables(:name => name,
              :description => new_resource.description,
              :storages_config  => ::MoBackup::Storage.generate_config(default_keep, new_resource.storages),
              :databases_config => ::MoBackup::Database.generate_config(new_resource.databases),
              :notifiers_config => ::MoBackup::Notifier.generate_config(new_resource.notifiers),
              :archives => Array(new_resource.archives),
              :archives_exclude => Array(new_resource.exclude),
              :use_sudo => new_resource.use_sudo,
              :root => new_resource.root,
              :compress => new_resource.compress)
  end
end

def backup_periods
  {}.tap do |backup_periods|
    Mash.new(
      :daily => {
        :method => :daily_keeps,
        :hour => (new_resource.start_hour..new_resource.end_hour).to_a.sample,
        :minute => (0..59).to_a.sample
      },
      :weekly => {
        :method => :weekly_keeps,
        :week_day => new_resource.week_day,
        :hour => (new_resource.start_hour..new_resource.end_hour).to_a.sample,
        :minute => (0..59).to_a.sample
      },
      :monthly => {
        :method => :monthly_keeps,
        :month_day => new_resource.month_day,
        :hour => (new_resource.start_hour..new_resource.end_hour).to_a.sample,
        :minute => (0..59).to_a.sample
      }
    ).each do |p,options|
      default = Mash.new(
        'minute'    => '*',
        'hour'      => '*',
        'month_day' => '*',
        'month'     => '*',
        'week_day'  => '*'
      )

      keep_count = new_resource.send options[:method]

      options.delete :method

      backup_periods[p] = Mash.new('keep' => keep_count).merge(default).merge(options) if keep_count > 0

    end
  end
end

def cron_backup(create, name, period_name, options)
  me = self
  cron "backup #{name} #{period_name}" do
    minute  options['minute']
    hour    options['hour']
    day     options['month_day']
    month   options['month']
    weekday options['week_day']
    user    new_resource.user
    command me.backup_command name
    shell   "/bin/bash"
    action  create ? :create : :delete
  end
end
