#!/usr/bin/env ruby
# frozen_string_literal: true

class Day9
  attr_reader :lines

  def initialize(lines)
    @lines = lines.map { |line| line.chars.map(&:to_i).freeze }.freeze
  end

  def part1
    low_points.map { |x, y| risk_level(x, y) }.sum
  end


  private

  def all_coords
    lines.flat_map.with_index do |line, y|
      line.map.with_index do |_, x|
        [x, y]
      end
    end
  end

  def low_points
    all_coords.select do |x, y|
      neighbors(x, y)
        .map { |coords| height(*coords) }
        .all? { |nheight| nheight > height(x, y) }
    end
  end

  def height(x, y)
    lines[y][x]
  end

  def risk_level(x, y)
    1 + height(x, y)
  end

  def neighbors(x, y)
    r = []
    uy = lines.length - 1
    ux = lines[0].length - 1
    r << [x - 1, y] if x.positive?
    r << [x, y - 1] if y.positive?
    r << [x, y + 1] if y < uy
    r << [x + 1, y] if x < ux

    r
  end
end

day9 = Day9.new(ARGF.map(&:chomp).to_a)
p part1: day9.part1
