include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  Chef::Log.info("Incoming deploy for #{application}")

  if application != 'matchmaker'
    Chef::Log.debug("Skipping deploy for application #{application} as it is not a matchmaker")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  opsworks_nodejs do
    deploy_data deploy
    app application
  end

  ruby_block "restart node.js application #{application}" do
    block do
      Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
    end
  end
end
