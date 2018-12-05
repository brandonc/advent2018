require "date"

# sort, guard > minute hist w/ total asleep

def deserialize_log(line)
  date, event = line.split("]", 2).map(&:strip)
  {
    date: DateTime.strptime(date, '[%Y-%m-%d %H:%M'),
    event: event
  }
end

log = ARGF.to_a.map { |line| deserialize_log(line) }.sort_by { |entry| entry[:date] }

def histogram_guard_sleep(log)
  histogram = Hash.new { |hash, key| hash[key] = Array.new(60, 0) }
  guard = nil
  fell_asleep_minute = -1

  log.each do |entry|
    if entry[:event] == "wakes up"
      fail "Guard not asleep" if fell_asleep_minute == -1
      fail "No guard" if guard.nil?
      (fell_asleep_minute..entry[:date].minute).each do |m|
        histogram[guard][m] += 1
      end
      fell_asleep_minute = -1
    elsif entry[:event] == "falls asleep"
      fail "No guard" if guard.nil?
      fell_asleep_minute = entry[:date].minute
    else
      fail "Didn't awake" unless fell_asleep_minute == -1
      guard = entry[:event].match(/^Guard \#([0-9]+) begins shift$/)[1].to_i
    end
  end

  histogram
end

def guard_most_minutes_asleep(histogram)
  max = 0
  guard = -1
  histogram.each do |key, values|
    asleep = values.reduce(:+)
    if asleep > max
      max = asleep
      guard = key
    end
  end

  guard
end

def most_asleep_minute(values)
  index = 0
  max = 0
  values.each.with_index do |v, n|
    if v > max
      max = v
      index = n
    end
  end

  puts values
  fail "#{values[index]}, #{max}" if values[index] != max
  index
end

def histogram_minutes(log)
  hist = Hash.new { |hash, key| hash[key] = Hash.new { 0 } }
  guard = nil
  fell_asleep_minute = -1

  log.each do |entry|
    if entry[:event] == "wakes up"
      fail "Guard not asleep" if fell_asleep_minute == -1
      fail "No guard" if guard.nil?
      (fell_asleep_minute..entry[:date].minute).each do |m|
        hist[m][guard] += 1
      end
      fell_asleep_minute = -1
    elsif entry[:event] == "falls asleep"
      fail "No guard" if guard.nil?
      fell_asleep_minute = entry[:date].minute
    else
      fail "Didn't awake" unless fell_asleep_minute == -1
      guard = entry[:event].match(/^Guard \#([0-9]+) begins shift$/)[1].to_i
    end
  end

  hist
end

def minute_guard_most_asleep(hist)
  max = 0
  minute = -1
  guard = -1

  hist.each do |m, guards|
    guards.each do |g, total|
      if total > max
        max = total
        minute = m
        guard = g
      end
    end
  end

  [minute, guard]
end

hist = histogram_guard_sleep(log)
guard = guard_most_minutes_asleep(hist)
minute = most_asleep_minute(hist[guard])
puts "guard most asleep was #{guard} at #{minute}"
puts "checksum #{guard * minute}"

hist_minutes = histogram_minutes(log)
two_minute, two_guard = minute_guard_most_asleep(hist_minutes)
puts "minute most asleep was #{two_minute} by #{two_guard} (#{hist_minutes[two_minute][two_guard]})"
puts "checksum #{two_minute * two_guard}"
