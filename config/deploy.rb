require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'    # for rvm support. (https://rvm.io)
require 'mina/nginx'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'rails-searchkick-example'
set :domain, '3.88.70.34'
set :deploy_to, '/var/deploy/rails-searchkick-example'
set :repository, 'git@github.com:lalitlogical/rails-searchkick-example.git'
set :branch, 'master'

# Optional settings:
set :user, 'ubuntu'          # Username in the server to SSH to.
set :identity_file, '~/.ssh/LalitMinaDeploy.pem'
set :port, '22'           # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml', 'tmp/pids', 'tmp/sockets')
set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
set :rvm_use_path, '/usr/local/rvm/scripts/rvm'

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-2.3.1@default'
end

namespace :puma do
  set :web_server, :puma

  set :puma_role,      -> { user }
  set :puma_env,       -> { fetch(:rails_env, 'production') }
  set :puma_config,    -> { "#{fetch(:shared_path)}/config/puma.rb" }
  set :puma_socket,    -> { "#{fetch(:shared_path)}/tmp/sockets/puma.sock" }
  set :puma_state,     -> { "#{fetch(:shared_path)}/tmp/sockets/puma.state" }
  set :puma_pid,       -> { "#{fetch(:shared_path)}/tmp/pids/puma.pid" }
  set :puma_cmd,       -> { "#{fetch(:bundle_prefix)} puma" }
  set :pumactl_cmd,    -> { "#{fetch(:bundle_prefix)} pumactl" }
  set :pumactl_socket, -> { "#{fetch(:shared_path)}/tmp/sockets/pumactl.sock" }

  desc 'Start puma'
  task :start => :remote_environment do
    command %[
      if [ -e '#{fetch(:pumactl_socket)}' ]; then
        echo 'Puma is already running!';
      else
        if [ -e '#{fetch(:puma_config)}' ]; then
          cd #{fetch(:current_path)} && #{fetch(:puma_cmd)} -q -d -e #{fetch(:puma_env)} -C #{fetch(:puma_config)}
        else
          cd #{fetch(:current_path)} && #{fetch(:puma_cmd)} -q -d -e #{fetch(:puma_env)} -b 'unix://#{fetch(:puma_socket)}' -S #{fetch(:puma_state)} --pidfile #{fetch(:puma_pid)} --control 'unix://#{fetch(:pumactl_socket)}'
        fi
      fi
    ]
  end

  desc 'Stop puma'
  task stop: :remote_environment do
    command %[
      if [ -e '#{fetch(:pumactl_socket)}' ]; then
        cd #{fetch(:current_path)} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} stop
        rm -f '#{fetch(:pumactl_socket)}'
      else
        echo 'Puma is not running!';
      fi
    ]
  end

  desc 'Restart puma'
  task restart: :remote_environment do
    invoke :'puma:stop'
    invoke :'puma:start'
  end

  desc 'Restart puma (phased restart)'
  task phased_restart: :remote_environment do
    command %[
      if [ -e '#{fetch(:pumactl_socket)}' ]; then
        cd #{fetch(:current_path)} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} --pidfile #{fetch(:puma_pid)} phased-restart
      else
        echo 'Puma is not running!';
      fi
    ]
  end
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # Puma needs a place to store its pid file and socket file.
  command %(mkdir -p "#{fetch(:shared_path)}/tmp/sockets")
  command %(chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/sockets")
  command %(mkdir -p "#{fetch(:shared_path)}/tmp/pids")
  command %(chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/pids")
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:phased_restart'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
