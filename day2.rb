#!/usr/bin/env ruby

commands = ARGF.to_a

puts 'Part 1'
h = 0
v = 0
commands.each do |line|
  cmd, num = line.chomp.split(' ')
  num = num.to_i
  case cmd
    when 'forward'
      h += num
    when 'down'
      v += num
    when 'up'
      v -= num
    else
      raise StandardError("Unexpected command #{cmd}")
  end
end
puts [h, v, h * v]

puts 'Part 2'
h = 0
v = 0
aim = 0
commands.each do |line|
  cmd, num = line.chomp.split(' ')
  num = num.to_i
  case cmd
    when 'forward'
      h += num
      v += num * aim
    when 'down'
      aim += num
    when 'up'
      aim -= num
    else
      raise StandardError("Unexpected command #{cmd}")
  end
end
puts [h, v, aim, h * v]
