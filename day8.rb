#!/usr/bin/env ruby

class Day8
  attr_reader :list
  def initialize(lines)
    @list = lines
      .map(&:chomp)
      .map { |item|
        item
          .split(' | ')
          .map { |sec| sec.split(' ') }
      }
  end

  def part1
    list.sum { |_, output|
      output.count { |digit| [2, 3, 4, 7].include? digit.length }
    }
  end
end

day8 = Day8.new(ARGF)
p :part1, day8.part1
