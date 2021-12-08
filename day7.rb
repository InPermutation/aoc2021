#!/usr/bin/env ruby

class Day7
  attr_reader :list

  def initialize(list)
    @list = list.split(',').map(&:to_i)
  end

  def part1
    lowest_cost { |tgt| linear(tgt) }
  end

  def part2
    lowest_cost { |tgt| sum_dist(tgt) }
  end

  private

  def lowest_cost(&block)
    min = list.min
    max = list.max
    lowest = (min..max).min_by(&block)

    yield lowest
  end

  def linear(tgt)
    list.map { |pos| (pos - tgt).abs }.sum
  end

  def sum_dist(tgt)
    list.map do |pos|
      d = (pos - tgt).abs
      (0..d).sum
    end.sum
  end
end

day7 = Day7.new ARGF.first.chomp
p :part1, day7.part1
p :part2, day7.part2
