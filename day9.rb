#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

Point = Struct.new(:x, :y)

class HeightMap
  attr_reader :width, :height

  def initialize(lines)
    @heights = lines.map { |line| line.chars.map(&:to_i).freeze }.freeze
    @height = @heights.length
    @width = @heights[0].length
  end

  def height_at(point)
    @heights[point.y][point.x]
  end
end

class Day9
  def part1
    # Sum of the risk levels of all low points
    low_points.map(&method(:risk_level)).sum
  end

  def part2
    # Multiply together the sizes of the three largest basins
    basins.map(&:length).sort.reverse.take(3).inject(&:*)
  end

  private

  attr_reader :height_map, :all_coords

  def initialize(lines)
    @height_map = HeightMap.new(lines)
    @all_coords = height_map.width.times.to_a
                            .product(height_map.height.times.to_a)
                            .map { |x, y| Point.new(x, y) }
  end

  def low_points
    all_coords.select do |coords|
      neighbors(coords)
        .all? { |neighbor| height(neighbor) > height(coords) }
    end
  end

  def height(coords)
    height_map.height_at(coords)
  end

  def risk_level(coords)
    1 + height(coords)
  end

  NEIGHBORLY_DIRECTIONS = [
    [0, 1].freeze,
    [0, -1].freeze,
    [1, 0].freeze,
    [-1, 0].freeze
  ].freeze

  def neighbors(coords)
    NEIGHBORLY_DIRECTIONS
      .map { |dx, dy| Point.new(coords.x + dx, coords.y + dy) }
      .select { |p| (0...height_map.width).include? p.x }
      .select { |p| (0...height_map.height).include? p.y }
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
