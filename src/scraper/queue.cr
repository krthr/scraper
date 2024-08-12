require "log"

alias Task = ->

class Queue
  Log = ::Log.for(self)

  def initialize(@capacity = 5, @wait_for = 1.second)
    @tasks = [] of Task
    self.start
  end

  def empty?
    @tasks.empty?
  end

  def add(&block)
    Log.info { "Adding a new task..." }
    @tasks << block
  end

  private def start
    Log.info { "Starting queue..." }

    spawn do
      loop do
        tasks = @tasks.pop(@capacity)
        size = tasks.size

        ready = Channel(Nil).new

        tasks.each do |task|
          spawn do
            Log.info { "Running new task..." }

            begin
              task.call
            ensure
              ready.send nil
            end
          end
        end

        size.times { ready.receive? }

        sleep(@wait_for)
      end
    end
  end
end
