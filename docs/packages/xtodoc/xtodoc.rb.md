```rb#! /usr/bin/env ruby
```
  # About
  xtodoc takes in commented files and outputs them in markdown. Markdown formatting used
  within the code is respected.

  # Why?
  I wrote xtodoc to generate documentation for my NixOS configuration. Since more than
  nix code is used xtodoc had to be able to generate documentation for many
  languages.
  ## Why not Org files?
  I don't personally always use Emacs (this was typed in Neovim) and I didn't want I nor
  anyone else to depend on it for editing any code.

  # License
  This code is licensed under GPLv3.
```rb
require 'pathname'
require 'fileutils'
def top_parent_dir(path)
  Pathname.new(path).each_filename.to_a[0]
end

def nix(file, output_file, file_extension)
  output_file.write("```#{file_extension}")
  File.open(file).each_line do |line|
    if line.chomp.lstrip.start_with? '/*'
      output_file.puts('```')
    elsif line.chomp.lstrip.start_with? '*/'
      output_file.puts("```#{file_extension}")
    else
      output_file.write(line)
    end
  end
  output_file.puts('```')
end

def rb(file, output_file, file_extension)
  output_file.write("```#{file_extension}")
  File.open(file).each_line do |line|
    if line.chomp.start_with? '=begin'
      output_file.puts('```')
    elsif line.chomp.start_with? '=end'
      output_file.puts("```#{file_extension}")
    else
      output_file.write(line)
    end
  end
  output_file.puts('```')
end

def other(file, output_file)
  File.open(file).each_line do |line|
    output_file.write(line)
  end
end

def mdfile(file, output_dir)
  case File.extname(file).delete('.')
  when 'nix'
    nix(file, File.new("#{output_dir}/#{file}.md", 'w'), 'nix')
  when 'rb'
    rb(file, File.new("#{output_dir}/#{file}.md", 'w'), 'rb')
  when 'md'
    other(file, File.new("#{output_dir}/#{file}", 'w'))
  else
    other(file, File.new("#{output_dir}/#{file}.md", 'w'))
  end
end

OUTPUT_DIR = 'docs'
resource_paths = Dir.glob('**/*').reject do |path|
  top_parent_dir(path) == OUTPUT_DIR || File.directory?(path)
end
if Pathname.new(OUTPUT_DIR).exist?
  FileUtils.remove_dir OUTPUT_DIR
end
directories = Dir.glob('**/*').select do |path|
  File.directory?(path) and path != OUTPUT_DIR
end
FileUtils.mkpath OUTPUT_DIR
for dir in directories
  FileUtils.mkpath "#{OUTPUT_DIR}/#{dir}"
end
for file in resource_paths
  mdfile(file, OUTPUT_DIR)
end
```
