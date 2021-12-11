#!/usr/bin/env ruby
# frozen_string_literal: true

class Day11
  def print_both_parts!
    flashes = 0
    first_sync = nil
    step = 0
    until first_sync && step >= 100
      flashes += step!
      step += 1

      puts "part 1: #{flashes}" if step == 100
      first_sync ||= step if all_zero?
    end
    puts "part 2: #{first_sync}"
  end

  private

  attr_reader :grid

  def initialize(lines)
    @grid = lines.map do |line|
      line.chars.map(&:to_i).to_a
    end.to_a.freeze
  end

  def indexes
    grid.length.times.flat_map do |y|
      grid[y].length.times.map do |x|
        [x, y]
      end
    end
  end

  def all_zero?
    indexes.all? { |x, y| grid[y][x].zero? }
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

  def step!
    flashes = 0
    increase_by_1!
    loop do
      f = flash!
      flashes += f
      break if f.zero?
    end
    flashes
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

day11 = Day11.new(ARGF.map(&:chomp))
day11.print_both_parts!
