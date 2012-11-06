#!/usr/bin/env ruby
require 'rubygems'
require 'pony'
begin 
while line = STDIN.readline do
  puts line
  action = line if line.start_with?("Started")
  if line =~ /Error/
    message = "Problem in #{action}\n#{line}"
    Pony.mail :from => 'performance@dialoogtafels.nl', :to => 'rob@qwan.it', :subject => 'dialoogtafels performance notice', :body => message, :via => :sendmail
    puts 'sent mail'
  end
end
rescue EOFError
  puts "bye" 
end
