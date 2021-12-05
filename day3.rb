#!/usr/bin/env ruby

diagnostics = ARGF.to_a
len = diagnostics[0].chomp.length

tallies = Array.new(len) { Hash.new } # TODO: Enumerable.tally with Ruby 2.7+
diagnostics.each do |diagnostic|
  for pos in 0..len-1 do
    ch = diagnostic[pos]
    tallies[pos][ch] ||= 0
    tallies[pos][ch] += 1
  end
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

