#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'bundler'
Bundler.require :rake
begin
  require "vlad"
  Vlad.load(:app => nil, :scm => "git", :web => nil)
rescue LoadError
  # do nothing
end

require File.expand_path('../config/application', __FILE__)

Tafelmanager2::Application.load_tasks

