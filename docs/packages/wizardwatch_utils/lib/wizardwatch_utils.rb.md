```rb#! /usr/bin/env ruby

# require_relative "wizardwatch_utils/version"
require 'socket'

def update(input)
  hostname = Socket.gethostname
  if input[1] != hostname
    puts 'THE HOSTNAME DOES NOT MATCH THE SELECTED CONFIGURATION.'
    puts 'You entered ' + input[1] + ', the hostname is ' + hostname + '.'
  end
  puts 'Are you sure you want to update this computer? yes/no'
  confirm = $stdin.gets
  if confirm.chomp == 'yes'
    puts `sudo nixos-rebuild switch --flake \.\##{hostname}`
  end
end

def apply_user(input)
  puts "Do you want to install (update) user #{input[1]} this computer? yes/no"
  confirm = $stdin.gets
  if confirm.chomp == 'yes'
    puts `nix build -v .#homeManagerConfigurations.#{input[1]}.activationPackage`
    puts `bash ./result/activate`
  end
end

def unlock()
    puts 'Are you sure you want to update the lock? yes/no'
    confirm = $stdin.gets
--  if confirm.chomp == 'yes'
      puts `nix flake update`
    end
end

input = ARGV
case input.first
when 'up' || 'update'
  update(input)
when 'user'
  apply_user(input)
when 'unlock'
  unlock
end
```
