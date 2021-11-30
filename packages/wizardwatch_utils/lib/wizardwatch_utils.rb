#! /usr/bin/env ruby

# require_relative "wizardwatch_utils/version"
require 'socket'

def update(input)
  hostname = Socket.gethostname
  if input[1] != hostname then
    puts "THE HOSTNAME DOES NOT MATCH THE SELECTED CONFIGURATION." 
    puts "You entered " + input[1] + ", the hostname is " + hostname + "."
  end
  puts "Are you sure you want to update this computer? yes or no"
  confirm = $stdin.gets
  if confirm.chomp == "yes" then
    puts `sudo nixos-rebuild switch --flake \.\##{hostname}`
  end
end

input = ARGV
case input.first()
when "update"
  update(input)
end
