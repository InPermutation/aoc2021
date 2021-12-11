#!/usr/bin/env ruby
# frozen_string_literal: true

class Day11
  def part1
  end

  def part2
  end

  private

  attr_reader :initial_energy

  def initialize(lines)
    @initial_energy = lines.map do |line|
      line.chars.map(&:to_i).to_a.freeze
    end.to_a.freeze
    p @initial_energy
  end
end

day11 = Day11.new(ARGF.map(&:chomp))
p :part1, day11.part1
p :part2, day11.part2
