#!/usr/bin/env ruby

puts ARGF.map(&:to_i)
  .each_cons(2)
  .count { |a| a[0] < a[1] }
