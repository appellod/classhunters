class Sleeper
  @queue = :sleep

  def self.perform(seconds)
    puts "Worked"
  end
end