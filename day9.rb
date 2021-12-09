#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

class Day9
  attr_reader :lines

  def initialize(lines)
    @lines = lines.map { |line| line.chars.map(&:to_i).freeze }.freeze
  end

  def part1
    low_points.map { |coords| risk_level(coords) }.sum
  end

  def part2
    # Product of the size of the three largest basins
    basins.map(&:length).sort.reverse.take(3).inject(&:*)
  end

  private

  def all_coords
    lines.flat_map.with_index do |line, y|
      line.length.times.map do |x|
        [x, y]
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
    x, y = coords
    lines[y][x]
  end

  def risk_level(coords)
    1 + height(coords)
  end

  def neighbors(coords)
    x, y = coords
    r = []
    uy = lines.length - 1
    ux = lines[0].length - 1
    r << [x - 1, y] if x.positive?
    r << [x, y - 1] if y.positive?
    r << [x, y + 1] if y < uy
    r << [x + 1, y] if x < ux

    r
  end

  def basins
    low_points.map { |coords| flood_fill(coords) }
  end

  def flood_fill(coords)
    basin = Set.new([coords])
    explore_from = [coords]

    until explore_from.empty?
      discovered = neighbors(explore_from.shift)
                   .reject { |coords| height(coords) == 9 }
                   .reject { |coords| basin.include? coords }
      basin = basin.merge(discovered)
      explore_from.push(*discovered)
    end

    basin.to_a
  end
end

day9 = Day9.new(ARGF.map(&:chomp).to_a)
p part1: day9.part1
p part2: day9.part2
