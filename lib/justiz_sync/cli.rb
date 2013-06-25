require 'thor'
require 'awesome_print'

module JustizSync
  class Cli < Thor
    desc "hello NAME", "say hello to NAME"
    def hello(name)
      puts "Hello #{name}"
    end

    option :user, required: true, default: 'guest'
    option :password, required: true, default: 'guest'
    option :url, required: true, default: 'http://localhost:8080'
    desc 'sync', 'sync all records from justiz to opencrx'
    def sync
      ap options
    end
  end
end
