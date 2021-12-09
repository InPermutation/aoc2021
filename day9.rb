#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

class Day9
  def part1
    low_points.map(&method(:risk_level)).sum
  end

  def part2
    # Product of the size of the three largest basins
    basins.map(&:length).sort.reverse.take(3).inject(&:*)
  end

  private

  Point = Struct.new(:x, :y)

  attr_reader :lines, :all_coords

  def initialize(lines)
    @lines = lines.map { |line| line.chars.map(&:to_i).freeze }.freeze
    @all_coords = lines.flat_map.with_index do |line, y|
      line.length.times.map do |x|
        Point.new(x, y)
      end
    end
  end

  def low_points
    all_coords.select do |coords|
      neighbors(coords)
        .all? { |neighbor| height(neighbor) > height(coords) }
    end
  end

  def height(coords)
    lines[coords.y][coords.x]
  end

  def risk_level(coords)
    1 + height(coords)
  end

  def neighbors(coords)
    [left(coords), up(coords), right(coords), down(coords)].compact
  end

  def left(coords)
    x, y = coords.x, coords.y
    Point.new(x - 1, y) if x.positive?
  end

  def up(coords)
    x, y = coords.x, coords.y
    Point.new(x, y - 1) if y.positive?
  end

  def right(coords)
    x, y = coords.x, coords.y
    Point.new(x + 1, y) if x + 1 < lines[y].length
  end

  def down(coords)
    x, y = coords.x, coords.y
    Point.new(x, y + 1) if y + 1 < lines.length
  end

  def basins
    low_points.map(&method(:flood_fill))
  end

  def flood_fill(coords)
    basin = Set.new([coords])
    explore_from = [coords]

    until explore_from.empty?
      discovered = neighbors(explore_from.shift)
                   .reject { |neighbor| height(neighbor) == 9 }
                   .reject(&basin.method(:include?))
      basin = basin.merge(discovered)
      explore_from.push(*discovered)
    end

    basin.to_a
  end
end

day9 = Day9.new(ARGF.map(&:chomp).to_a)
p part1: day9.part1
p part2: day9.part2
