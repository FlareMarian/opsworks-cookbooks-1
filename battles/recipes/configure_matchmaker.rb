Chef::Log.info("Should configure matchmaker")

mongodbhost = nil
memcachedhost = nil
rabbitmqhost = nil

node[:opsworks][:layers][:mongo][:instances].each do |instance_name, instance|
	mongodbhost = instance[:private_ip]
	Chef::Log.info("Found MongoDB instance #{instance_name} at #{instance[:private_ip]}")
end

node[:opsworks][:layers][:rabbitmq][:instances].each do |instance_name, instance|
	rabbitmqhost = instance[:private_ip]
	Chef::Log.info("Found RabbitMQ instance #{instance_name} at #{instance[:private_ip]}")
end

node[:opsworks][:layers][:memcached][:instances].each do |instance_name, instance|
	memcachedhost = instance[:private_ip]
	Chef::Log.info("Found Memcached instance #{instance_name} at #{instance[:private_ip]}")
end

deploy = node[:deploy][:matchmaker]

template "#{deploy[:deploy_to]}/current/matchmaker/matchmaker.cfg" do
	source 'matchmaker.cfg.erb'
	mode '0660'
	owner deploy[:user]
	group deploy[:group]
	variables(
		:mongodbhost => mongodbhost, 
		:memcachedhost => memcachedhost, 
		:rabbitmqhost => rabbitmqhost
	)
end

template "/etc/monit/conf.d/matchmaker-#{application}.monitrc" do
	source 'matchmaker.monitrc.erb'
	owner 'root'
	group 'root'
	mode '0644'
	variables(
	  :deploy => deploy,
	  :application_name => application,

	)
	notifies :restart, "service[monit]", :immediately
end

