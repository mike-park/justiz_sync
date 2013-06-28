module JustizSync
  class Stream
    def initialize
      @ids= []
      @total_items = 0
      @new_items = 0
    end

    def sync(court)
      @ids << court.id
      @total_items += 1
      @new_items += OpencrxCourt.new(court).sync
    end

    def close(delete_unused = false)
      all_ids = OpencrxCourt.all_ids
      unused = all_ids - @ids
      puts "#{@total_items} processed"
      puts "#{@new_items} new entrie(s)"
      if delete_unused
        OpencrxCourt.destroy(unused)
        puts "#{unused.length} deleted entrie(s)"
      end
    end
  end
end
