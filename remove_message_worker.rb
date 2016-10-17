require 'sucker_punch'
require_relative 'app'

# module SuckerPunch
class RemoveMessageWorker

  include SuckerPunch::Job

  # SuckerPunch.config do
  # queue name: :message_queue, worker: RemoveMessageWorker, workers: 2
  # end
  def diff_time_2(time)
    Time.now - time
  end

  def perform
    a = Messages.all
    i = 0
    while i < a.size
      if a[i].destruction != 1 && diff_time_2(a[i].created_at) >= 100
        Messages.find(a[i].id.to_i).destroy

      end
      i += 1
    end
  end
end

# SuckerPunch::Queue[:message_queue].async.perform(10)
# RemoveMessageWorker.new.async.perform