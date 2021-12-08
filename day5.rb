#!/usr/bin/env ruby

require 'set'

class Day5
  attr_reader :lines
  def initialize(lines)
    @lines = lines.map &Day5.method(:parse)
  end

  def self.parse(line)
    line.split(' -> ')
      .map(&method(:parse_point))
  end

  def self.parse_point(coords)
    coords.split(',').map(&:to_i)
  end

  def only_horiz_and_vert
    @lines.select { |from, to|
      from[0] == to[0] || from[1] == to[1]
    }
  end

  def pointsplosion(lines)
    lines.flat_map { |points|
      if points.first[0] == points.last[0] then
        x = points.first[0]
        ys = points.map(&:last).sort
        Range.new(*ys).map { |y| [x, y] }
      else
        y = points.first[1]
        xs = points.map(&:first).sort
        Range.new(*xs).map { |x| [x, y] }
      end
    }
  end

  def part1
    pointsplosion(only_horiz_and_vert).tally.select { |p, c| c > 1 }.length
  end
end

day5 = Day5.new(ARGF.to_a.map(&:chomp))
p day5.part1
