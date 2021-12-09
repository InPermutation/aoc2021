#!/usr/bin/env ruby
# frozen_string_literal: true

class Day9
  attr_reader :lines

  def initialize(lines)
    @lines = lines.map { |line| line.chars.map(&:to_i).freeze }.freeze
  end

  def part1
    low_points.map(&:succ).sum
  end

  private

  def low_points
    lines.flat_map.with_index do |line, y|
      line.select.with_index do |height, x|
        neighbors(x, y)
          .map { |coords| height(*coords) }
          .all? { |nheight| nheight > height }
      end
    end
  end

  def height(x, y)
    lines[y][x]
  end

  def neighbors(x, y)
    r = []
    uy = lines.length - 1
    ux = lines[0].length - 1
    r << [x - 1, y] if x > 0
    r << [x, y - 1] if y > 0
    r << [x, y + 1] if y < uy
    r << [x + 1, y] if x < ux

    r
  end
end

day9 = Day9.new(ARGF.map(&:chomp).to_a)
p day9.part1