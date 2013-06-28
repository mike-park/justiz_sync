require 'rspec'
require 'justiz_sync'
require 'awesome_print'

def delete_courts(id)
  while (crx = JustizSync::OpencrxCourt.find(id))
    crx.destroy
  end
end
