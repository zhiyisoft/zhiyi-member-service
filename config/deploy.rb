set :application, "zhiyi-member-service"
set :repository,  "https://github.com/zhiyisoft/zhiyi-member-service.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

require "bundler/capistrano"

set :scm, :git

role :web, "121.199.22.195"                          # Your HTTP server, Apache/etc
role :app, "121.199.22.195"                          # This may be the same as your `Web` server
role :db,  "121.199.22.195", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

set :deploy_to, '/zhiyisoft/app/zhiyi-member-service'

set :runner, 'nobody'
set :user, 'root'
set :use_sudo, false

default_environment["PATH"] = "/zhiyisoft/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

