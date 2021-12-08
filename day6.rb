#!/usr/bin/env ruby

class Day6
  attr_reader :list
  def initialize(list)
    t = list.split(',').map(&:to_i).tally
    t.default = 0
    @list = (0..8).map { |i| t[i] }
  end

  def part1
    state_at(80)
  end

  def part2
    state_at(256)
  end

  def state_at(n)
    school = list.clone
    n.times { school = incr(school) }
    school.sum
  end

  def incr(school)
    spawners = school[0]
    for i in 1..8 do
      school[i-1] = school[i]
    end
    school[8] = spawners
    school[6] += spawners

    school
  end
end

day6 = Day6.new(ARGF.to_a.map(&:chomp).first)
p :part1, day6.part1
p :part2, day6.part2
