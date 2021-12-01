#!/usr/bin/env ruby

measurements = ARGF.map(&:to_i)

puts 'Part 1'
puts measurements
  .each_cons(2)
  .count { |a| a[0] < a[1] }

puts 'Part 2'
puts measurements
  .each_cons(3)
  .map(&:sum)
  .each_cons(2)
  .count { |a| a[0] < a[1] }
