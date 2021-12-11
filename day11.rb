#!/usr/bin/env ruby
# frozen_string_literal: true

class Day11
  def part1
    step_forever!.take(100).sum
  end

  def part2
    1 + step_forever!.find_index { all_zero? }
  end

  private

  attr_reader :grid

  def initialize(lines)
    @grid = lines.map do |line|
      line.chars.map(&:to_i).to_a
    end.to_a.freeze
  end

  def indexes
    grid.flat_map.with_index do |line, y|
      line.length.times.map do |x|
        [x, y]
      end
    end
  end

  def all_zero?
    grid.all? { |line| line.all?(&:zero?) }
  end

  NEIGHBOR_DIRECTIONS =
    [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]

  def neighbors(x, y)
    NEIGHBOR_DIRECTIONS.map { |dx, dy| [x + dx, y + dy] }
  end

  def eligible_to_propagate?(x, y)
    return false if x.negative? || y.negative?

    grid.at(y)
      &.at(x)
      &.positive?
  end

  def increase_by_1!
    indexes.each { |x, y| grid[y][x] += 1 }
  end

  def step_forever!
    Enumerator.new { |y| loop { y << step! } }
  end

  def step!
    increase_by_1!
    flash_forever!.take_while(&:positive?).sum
  end

  def flash_forever!
    Enumerator.new { |y| loop { y << flash! } }
  end

  def flash!
    flashes = 0
    indexes.each do |x, y|
      next unless grid[y][x] > 9

      grid[y][x] = 0
      flashes += 1
      propagate!(x, y)
    end
    flashes
  end

  def propagate!(x, y)
    neighbors(x, y)
      .select { |x1, y1| eligible_to_propagate?(x1, y1) }
      .each { |x1, y1| grid[y1][x1] += 1 }
  end
end
lines = ARGF.map(&:chomp).freeze
day11 = Day11.new(lines.dup)
p part1: day11.part1
day11 = Day11.new(lines.dup)
p part2: day11.part2
