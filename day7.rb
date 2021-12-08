#!/usr/bin/env ruby

class Day7
  attr_reader :list
  def initialize(list)
    @list = list.split(',').map(&:to_i)
  end

  def part1
    min = list.min
    max = list.max
    lowest = (min..max).min_by do |tgt|
      cost(tgt)
    end

    cost(lowest)
  end

  def cost(tgt)
    list.map { |pos| (pos - tgt).abs }.sum
  end
end

day7 = Day7.new ARGF.first.chomp
p :part1, day7.part1

