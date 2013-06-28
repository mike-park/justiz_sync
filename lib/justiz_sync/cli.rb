require 'thor'
require 'justiz'

module JustizSync
  class Cli < Thor
    option :user, required: true, default: 'guest'
    option :password, required: true, default: 'guest'
    option :url, required: true, default: 'http://localhost:8080'
    option :state
    option :verbose
    desc 'sync', 'sync all records from justiz to opencrx'
    def sync
      transfer = Transfer.new(options)
      transfer.sync
    end
  end

  class Transfer
    attr_reader :options, :stream
    def initialize(options)
      @options = options
      STDOUT.sync = true
      open_connection
    end

    def sync
      @stream = Stream.new
      delete_unused = false
      if (state = options['state'])
        sync_state(state)
      else
        sync_all
        delete_unused = true
      end
      stream.close(delete_unused)
    end

    def sync_all
      states = scraper.states
      states.keys.each do |state|
        sync_state(state)
      end
    end

    def sync_state(state)
      courts = scraper.contacts_for(state)
      puts "Syncing #{state} #{courts.length} courts"
      sync_courts(courts)
    end

    def sync_courts(courts)
      courts.each_with_index do |court, index|
        stream.sync(court)
        puts if verbose && index && (index % 20 == 0)
        putc('.') if verbose
      end
      puts if verbose
    end

    private

    def verbose
      options.has_key?('verbose')
    end

    def open_connection
      Opencrx::connect(options['url'], options['user'], options['password'])
    end

    def scraper
      @scraper ||= Justiz::Scraper::Courts.new
    end
  end
end
