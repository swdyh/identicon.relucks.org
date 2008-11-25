require 'rubygems'
require 'rake/clean'
require 'fileutils'

REMOTE_HOST = 'relucks.org'
REMOTE_DIR  = 'www/usericons.relucks.org/'

task :default => :test

desc 'Run specs with story style output'
task :spec do
  sh 'specrb --specdox -Ilib:test test/*_test.rb'
end

desc 'Run specs with unit test style output'
task :test => FileList['test/*_test.rb'] do |t|
  suite = t.prerequisites.map{|f| "-r#{f.chomp('.rb')}"}.join(' ')
  sh "ruby -Ilib:test #{suite} -e ''", :verbose => false
end

namespace :remote do
  task :update do
    sh "ssh #{REMOTE_HOST} '#{REMOTE_DIR} && git pull && sudo /etc/init.d/apache2 restart'"
  end
end

CLEAN.include 'tmp/*'

