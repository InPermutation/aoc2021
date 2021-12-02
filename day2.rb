#!/usr/bin/env ruby

commands = ARGF.map { |line|
  parsed = line.chomp.split(' ', 2)
  [parsed[0], parsed[1].to_i]
}

puts 'Part 1'
h = 0
v = 0
commands.each do |cmd, num|
  case cmd
    when 'forward'
      h += num
    when 'down'
      v += num
    when 'up'
      v -= num
    else
      raise StandardError.new("Unexpected command #{cmd}")
  end
end
puts "#{h} x #{v} = #{h * v}"

puts 'Part 2'
h = 0
v = 0
aim = 0
commands.each do |cmd, num|
  case cmd
    when 'forward'
      h += num
      v += num * aim
    when 'down'
      aim += num
    when 'up'
      aim -= num
    else
      raise StandardError.new("Unexpected command #{cmd}")
  end
end
puts "#{h} x #{v} = #{h * v}  (aim=#{aim})"
