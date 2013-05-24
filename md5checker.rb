#!/usr/bin/env ruby

## mcabaj@gmail.com
## github.com/faja

require 'rubygems'
require 'optparse'
require 'yaml'
require 'digest/md5'
require 'colored'
require 'find'

options = {}

subtext = <<HELP
Subcommands:
	create :	create MD5 checksums FILE 
	check  :	read MD5 sums from the FILE and check them

See 'md5checker.rb SUBCOMMAND --help' for more information on a specific command.
HELP

global = OptionParser.new do |opts|
	opts.banner = "Usage: md5checker.rb subcommand [options]"
	
	opts.on("-h", "--help", "Show this message") do |h|
		options[:help] = h
		puts opts
		exit
	end

	opts.separator ""
	opts.separator subtext
end

subcommands = { 
  'create' => OptionParser.new do |opts|
    opts.banner = "Usage: md5checker.rb create [options]"
    opts.on("-h", "--help", "Show this message") do |h|
      options[:help] = h
      puts opts
      exit
    end

    options[:configfile] = 'md5checker.conf.yml'
    opts.on("-c", "--config [FILE]", "Configuration file") do |c|
      options[:configfile] = c || "md5checker.conf.yml"
    end

    options[:outputfile] = 'md5checker.out'
    opts.on("-o", "--output [FILE]", "Output file") do |o|
      options[:outputfile] = o || "md5checker.out"
    end

  end,

  'check' => OptionParser.new do |opts|
    opts.banner = "Usage: md5checker.rb check [options]"
    opts.on("-h", "--help", "Show this message") do |h|
      options[:help] = h
      puts opts
      exit
    end
    options[:configfile] = 'md5checker.conf.yml'
    opts.on("-c", "--config [FILE]", "Configuration file") do |c|
      options[:configfile] = c || 'md5checker.conf.yml'
    end
  end
}

begin
  global.order!
  command = ARGV.shift
  subcommands[command].order!
rescue => e
  puts "ERROR: Wrong syntax!\n".red
  puts global
  exit 1
end 


if command == 'create'

  if ! File.exist?(options[:configfile])
    puts "ERROR: Can't find config file: #{options[:configfile]}".red
    exit 1
  end

  begin
    config = YAML.load_file(options[:configfile])
  rescue
    puts "ERROR: Can't parse config file: #{options[:configfile]}".red
    exit 1
  end

  File.rename(options[:outputfile],"#{options[:outputfile]}.#{Time.now.to_i}") if File.exist?(options[:outputfile])
  outputfile=File.open(options[:outputfile],'a')

  if config['files']
    config['files'].each do |file|
      if ! File.exist?(file) or File.directory?(file)
        puts "WARNING: No such file: #{file}".yellow
        next
      end
      outputfile.write("#{Digest::MD5.hexdigest(File.read(file))} #{file}\n")
    end
  end

  if config['path']
    config['path'].each do |dir|
      if ! File.exist?(dir) or ! File.directory?(dir)
        puts "WARNING: No such directory: #{dir}".yellow
        next
      end
      Find.find(dir) do |file|
        next if File.directory?(file)
        next if config['path-only-bin'] and ! File.fnmatch('*bin*',file)
        outputfile.write("#{Digest::MD5.hexdigest(File.read(file))} #{file}\n")
      end
    end
  end

  if config['packages']
    %x{which #{config['package-manager']}}
    if $?.exitstatus != 0
      puts "WARNING: Can't find package-manager: \"#{config['package-manager']}\". Packages will not be checked.".yellow
    else
      if config['package-manager'] == 'rpm'
        config['packages'].each do |p|
          file_list = %x{#{config['package-manager']} -ql #{p} 2> /dev/null}
          if $?.exitstatus != 0
            puts "WARNING: No such package: #{p}".yellow 
            next
          end
          file_list.split.each do |file|
            next if File.directory?(file) or ! File.exist?(file)
            next if config['packages-only-bin'] and ! File.fnmatch('*bin*',file)
            outputfile.write("#{Digest::MD5.hexdigest(File.read(file))} #{file}\n")
          end
        end
      elsif config['package-manager'] == 'dpkg'
        config['packages'].each do |p|
          file_list = %x{#{config['package-manager']} -L #{p} 2> /dev/null}
          if $?.exitstatus != 0
            puts "WARNING: No such package: #{p}".yellow 
            next
          end
          file_list.split.each do |file|
            next if File.directory?(file) or ! File.exist?(file)
            next if config['packages-only-bin'] and ! File.fnmatch('*bin*',file)
            outputfile.write("#{Digest::MD5.hexdigest(File.read(file))} #{file}\n")
          end
        end
      else
        puts "WARNING: package-manager \"#{config['package-manager']}\" is not supported, sorrt:(".yellow
      end
    end 
  end

  outputfile.close
  puts "\nFILE: #{options[:outputfile]} was created.".green

elsif command == 'check'
  puts 'check'
end


