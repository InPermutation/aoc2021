#!/usr/bin/env ruby
diagnostics = ARGF.to_a
len = diagnostics[0].chomp.length

def tally(array)
  # TODO: in ruby 2.7 this should be built into Enumerable
  array.inject(Hash.new(0)) { |memo, item|
    memo[item] += 1
    memo
  }
end

tallies = len.times.map do |pos|
  tally(diagnostics.map { |diag| diag[pos] })
end

puts 'Part 1'
epsilon = tallies.map do |tally|
  tally['0'] > tally['1'] ? '0' : '1'
end.join.to_i(2)
gamma = tallies.map do |tally|
  tally['0'] < tally['1'] ? '0' : '1'
end.join.to_i(2)

puts "epsilon=#{epsilon}, gamma=#{gamma}. power=#{epsilon * gamma}"

puts 'Part 2'
