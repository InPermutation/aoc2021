#!/usr/bin/env ruby
# frozen_string_literal: true


class Day23
  def part1
  end

  def part2
  end

  private

  attr_reader :amphipods_init

  COSTS = {
    'A' => 1,   # Amber
    'B' => 10,  # Bronze
    'C' => 100, # Copper
    'D' => 1000 # Desert
  }
  def initialize(lines)
    p @amphipods_init = lines
      .drop(2)
      .take(2)
      .map { |line| line.gsub(/[^ABCD]/, '') }
  end
end

day23 = Day23.new(ARGF.map(&:chomp).freeze)
p part1: day23.part1
p part2: day23.part2
