
require 'nanoc3/tasks'
require 'fileutils'

namespace :create do

  desc "Creates a new article"
  task :article do
    $KCODE = 'UTF8'
    require 'active_support/core_ext'
    require 'active_support/multibyte'
    @ymd = Time.now.to_s(:db).split(' ')[0]
    if !ENV['title']
      $stderr.puts "\t[error] Missing title argument.\n\tusage: rake create:article title='article title'"
      exit 1
    end

    title = ENV['title'].capitalize
    path, filename, full_path = calc_path(title)

    if File.exists?(full_path)
      $stderr.puts "\t[error] Exists #{full_path}"
      exit 1
    end

    template = <<TEMPLATE
---
created_at: #{@ymd}
excerpt: 
kind: article
publish: true
tags: [misc]
title: "#{title.titleize}"
---

TODO: Add content to `#{full_path}.`
TEMPLATE

    FileUtils.mkdir_p(path) if !File.exists?(path)
    File.open(full_path, 'w') { |f| f.write(template) }
    $stdout.puts "\t[ok] Edit #{full_path}"
  end

  def calc_path(title)
    year, month_day = @ymd.split('-', 2)
    path = "content/" + year + "/" 
    filename = month_day + "_" + title.parameterize('-') + ".md"
    [path, filename, path + filename]
  end
end

BASE_URL = 'http://www.eyeshalfclosed.com/'

##
# Heroku-based Deployment
#
# Requires a Heroku Application (a heroku remote) that runs on Celadon Cedar
#
desc 'Deploy the website to Heroku using Git.'
task :deploy do
  prepare!
  compile!
  deploy!
  revert!
end

##
# Prepares the deployment environment
#
def prepare!
  %x[git checkout master]
  unless %x[git status] =~ /nothing to commit \(working directory clean\)/
    puts "Please commit your changes on the master branch before deploying!"
    exit 1
  end

  puts "Creating and moving in to \"deployment\" branch.."
  puts %x[git checkout -b deployment]

  puts "Removing \"output\" directory from .gitignore.."
  gitignore = File.read(".gitignore")
  File.open(".gitignore", "w") do |file|
    file.write(gitignore.gsub("output", ""))
  end

  change_base_url_to(BASE_URL)
end

##
# Re-compile by removing the output directory and re-compiling
#
def compile!
  puts "Compiling website.."
  puts %x[rm -rf output]
  puts %x[nanoc compile]
end

##
# Deploys the application via git to Heroku
#
def deploy!
  puts "Adding and committing compiled output for deployment.."
  puts %x[git add .]
  puts %x[git commit -a -m "temporary commit for deployment"]
  puts 'Deploying to Heroku..'
  puts %x[git push heroku HEAD:master --force]
end

##
# Moves back to the "master" branch and removes the "deployment" branch
#
def revert!
  %x[git checkout master]
  %x[git branch -D deployment]
end

##
# Use this method to change the base url in the configuration file
# so you can automate that instead of manually changing it everytime
# when you want to deploy the website
#
def change_base_url_to(url)
  puts "Changing Base URL to #{url}.."
  config = YAML.load_file('./config.yaml')
  config['base_url'] = url
  File.open('./config.yaml', 'w') do |file|
    file.write(config.to_yaml)
  end
end
