#!/usr/bin/env ruby

class Day6
  attr_reader :list
  def initialize(list)
    @list = list.split(',').map(&:to_i)
  end

  def part1
    state_at(80)
  end

  def state_at(n)
    school = list.clone
    for day in 1..n do
      school = incr(school)
      printf '.'
    end
    printf "\n"
    school.length
  end

  def incr(school)
    babies = [8] * school.select { |fish| fish == 0 }.length
    school.map { |fish| fish == 0 ? 6 : fish.pred } + babies
  end
end

day6 = Day6.new(ARGF.to_a.map(&:chomp).first)
p :part1, day6.part1
