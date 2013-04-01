include_recipe "git"
include_recipe "nodejs"
include_recipe "logrotate"

git node["statsd"]["dir"] do
  repository node["statsd"]["repository"]
  revision node["statsd"]["revision_tag"]
  action :sync
  notifies :restart, "service[statsd]"
end

directory node["statsd"]["conf_dir"] do
  action :create
end

template "#{node["statsd"]["conf_dir"]}/config.js" do
  mode "0644"
  source "config.js.erb"
  variables(
    :address           => node["statsd"]["address"],
    :port              => node["statsd"]["port"],
    :flush_interval    => node["statsd"]["flush_interval"],
    :graphite_port     => node["statsd"]["graphite_port"],
    :graphite_host     => node["statsd"]["graphite_host"],
    :gossip_girl       => node["statsd"]["gossip_girl"],
    :delete_idle_stats => node["statsd"]["delete_idle_stats"],
    :delete_gauges     => node["statsd"]["delete_gauges"],
    :delete_timers     => node["statsd"]["delete_timers"],
    :delete_sets       => node["statsd"]["delete_sets"],
    :delete_counters   => node["statsd"]["delete_counters"]
  )
  notifies :restart, "service[statsd]"
end


case node["platform_family"]
when "debian"
  template "/etc/init/statsd.conf" do
    mode "0644"
    source "statsd.conf.erb"
    variables(
      :log_file         => node["statsd"]["log_file"],
      :platform_version => node["platform_version"].to_f
    )
  end
when "rhel","fedora"
  template "/etc/init.d/statsd" do
    mode "0755"
    source "statsd.erb"
    variables(
      :log_file         => node["statsd"]["log_file"]
    )
  end
end

# installing the gossip_girl backend from https://github.com/wanelo/gossip_girl
# this backend aggregates stats (just like statsd) but forwards them to another
# 'downstream' statsd instance.
cookbook_file "#{node['statsd']['dir']}/backends/gossip_girl.js" do
  source "gossip_girl.js"
  mode "0644"
end

user "statsd" do
  system true
  shell "/bin/false"
end

file node["statsd"]["log_file"] do
  owner "statsd"
  action :create
end

logrotate_app "statsd" do
  cookbook "logrotate"
  path node["statsd"]["log_file"]
  frequency "daily"
  rotate 7
  create "644 root root"
end

service "statsd" do
  case node["platform"]
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
    #restart_command "sudo service statsd stop && sudo service statsd start"
  end
  action [ :enable, :start ]
  supports :start => true, :stop => true, :restart => true, :status => true
end
