#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

class Day5
  attr_reader :lines

  def initialize(lines)
    @lines = lines.map(&self.class.method(:parse))
  end

  def self.parse(line)
    line.split(' -> ')
        .map(&method(:parse_point))
  end

  def self.parse_point(coords)
    coords.split(',').map(&:to_i)
  end

  def only_horiz_and_vert
    @lines.select do |from, to|
      from[0] == to[0] || from[1] == to[1]
    end
  end

  def pointsplosion(lines)
    lines.flat_map do |points|
      if points.first[0] == points.last[0]
        x = points.first[0]
        ys = points.map(&:last).sort
        Range.new(*ys).map { |y| [x, y] }
      elsif points.first[1] == points.last[1]
        y = points.first[1]
        xs = points.map(&:first).sort
        Range.new(*xs).map { |x| [x, y] }
      else
        # diagonal
        xs = Range.new(*points.map(&:first).sort).to_a
        xs.reverse! if points.first[0] > points.last[0]
        ys = Range.new(*points.map(&:last).sort).to_a
        ys.reverse! if points.first[1] > points.last[1]
        raise StandardError, 'length mismatch' unless xs.length == ys.length

        xs.zip(ys)
      end
    end
  end

  def part1
    pointsplosion(only_horiz_and_vert).tally.select { |_p, c| c > 1 }.length
  end

  def part2
    pointsplosion(lines).tally.select { |_p, c| c > 1 }.length
  end
end

day5 = Day5.new(ARGF.to_a.map(&:chomp))
p 'Part 1', day5.part1
p 'Part 2', day5.part2
