#!/usr/bin/env ruby
diagnostics = ARGF.to_a.map(&:chomp)
len = diagnostics[0].length

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

def find_by(diagnostics, len)
  len.times.inject(diagnostics) { |remaining, pos|
    return remaining if remaining.length == 1
    t = tally(remaining.map { |diag| diag[pos] })
    remaining.select { |d| yield d, t, pos }
  }
end

o2 = find_by(diagnostics, len) { |diag, tallies, pos|
  diag[pos] == (tallies['0'] > tallies['1'] ? '0' : '1')
}.first.to_i(2)
co2 = find_by(diagnostics, len) { |diag, tallies, pos|
  diag[pos] == (tallies['1'] < tallies['0'] ? '1' : '0')
}.first.to_i(2)
life = o2 * co2
puts "o2=#{o2} co2=#{co2} life=#{life}"
