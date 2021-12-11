#!/usr/bin/env ruby
# frozen_string_literal: true

class Day11
  def part1
    grid = initial_energy.map(&:dup)
    flashes = 0
    100.times do
      increase_by_1!(grid)
      loop do
        f = flash!(grid)
        flashes += f
        break if f.zero?
      end
    end

    flashes
  end

  def part2
  end

  private

  attr_reader :initial_energy

  def initialize(lines)
    @initial_energy = lines.map do |line|
      line.chars.map(&:to_i).to_a.freeze
    end.to_a.freeze
  end

  def indexes(grid)
    grid.length.times.flat_map do |y|
      grid[y].length.times.map do |x|
        [x, y]
      end
    end
  end

  NEIGHBOR_DIRECTIONS =
    [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]

  def neighbors(x, y)
    NEIGHBOR_DIRECTIONS.map { |dx, dy| [x + dx, y + dy] }
  end

  def eligible_to_propagate?(grid, x, y)
    return false if x.negative? || y.negative?

    grid.at(y)
      &.at(x)
      &.positive?
  end

  def increase_by_1!(grid)
    indexes(grid).each { |x, y| grid[y][x] += 1 }
  end

  def flash!(grid)
    flashes = 0
    indexes(grid).each do |x, y|
      next unless grid[y][x] > 9

      grid[y][x] = 0
      flashes += 1

      neighbors(x, y)
        .select { |x1, y1| eligible_to_propagate?(grid, x1, y1) }
        .each { |x1, y1| grid[y1][x1] += 1 }
    end
    flashes
  end
end

day11 = Day11.new(ARGF.map(&:chomp))
p :part1, day11.part1
p :part2, day11.part2
