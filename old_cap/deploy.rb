set :application, "sprat"
set :repository,  "https://github.com/jhigman/sprat.git"
set :branch, "master"
set :scm, "git"

# Do not use sudo
# Comment the following two lines if you do use sudo
set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

ssh_options[:forward_agent] = true
ssh_options[:username] = 'testrun'
default_run_options[:pty] = true
set :use_sudo, false

set :user, 'testrun' # username on remote host
set :group, 'www' # group on remote host
set :runner, :user

set :host, "#{user}@testrunner.knowmalaria.co.uk"
set(:deploy_to) { "/home/#{user}" }
set :default_environment, {
  'PATH' => "/.rbenv/shims:/home/testrun/.rbenv/bin:$PATH"
}
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

role :web, host
role :app, host
set :rack_env, :production

# Where to deploy the app
set :current_path, "/home/testrun/current"
set :unicorn_conf, "/home/testrun/current/config/unicorn.rb"
set :unicorn_pid, "/home/testrun/shared/pids/unicorn.pid"

set :public_children, ["bootstrap","css"]

# Unicorn control tasks
namespace :deploy do
  task :restart do
    stop
    start
  end

  task :start do
    run "cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D"
  end

  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end

  after "deploy:create_symlink", :roles => [:app] do
    run "#{try_sudo} ln -nfs #{shared_path}/config/config.yml #{current_path}/config/"
  end
end

after "deploy:restart", :roles => [:app] do
  run "/home/testrun/bin/restart_resque_workers.sh"
end
