require 'optparse'
require 'libyear_bundler/version'
require "libyear_bundler/cli"
require 'ostruct'
require 'time'

module LibyearBundler
  # Uses OptionParser from Ruby's stdlib to hand command-line arguments
  class Options
    BANNER = <<-BANNER.freeze
Usage: libyear-bundler [Gemfile ...] [options]
https://github.com/jaredbeck/libyear-bundler/
    BANNER

    def initialize(argv)
      @argv = argv
      @options = ::OpenStruct.new
      @optparser = OptionParser.new do |opts|
        opts.banner = BANNER
        opts.program_name = 'libyear-bundler'
        opts.version = ::LibyearBundler::VERSION
        @options.send('libyears?=', true)

        opts.on_head('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end

        opts.on('--all', 'Calculate all metrics') do
          @options.send('libyears?=', true)
          @options.send('releases?=', true)
          @options.send('versions?=', true)
        end

        opts.on('--cache=CACHE_PATH', 'Use a cache across runs') do |cache_path|
          @options.cache_path = cache_path
        end

        opts.on('--libyears', '[default] Calculate libyears out-of-date') do
          @options.send('libyears?=', true)
        end

        opts.on('--releases', 'Calculate number of releases out-of-date') do
          @options.send('libyears?=', false)
          @options.send('releases?=', true)
        end

        opts.on('--versions', 'Calculate major, minor, and patch versions out-of-date') do
          @options.send('libyears?=', false)
          @options.send('versions?=', true)
        end

        opts.on('--grand-total', 'Return value for given metric(s)') do
          @options.send('grand_total?=', true)
        end

        opts.on('--max-time=ISO8601STRING', 'Foo') do |iso8601|
          @options.max_time = Time.iso8601(iso8601)
        end
      end
    end

    def parse
      @optparser.parse!(@argv)
      @options
    rescue OptionParser::InvalidOption => e
      warn e
      warn @optparser.help
      exit ::LibyearBundler::CLI::E_INVALID_CLI_ARG
    end
  end
end
