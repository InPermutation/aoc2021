#!/usr/bin/env ruby
# frozen_string_literal: true

class Day14
  def part1
    polymer = template
    10.times { polymer = insertion(polymer) }
    t = polymer.chars.tally
    min, max = t.values.minmax
    max - min
  end

  def part2
  end

  private

  attr_reader :template, :rules

  def initialize(lines)
    @template = lines.first
    @rules = lines
             .drop(2)
             .map { |line| line.split(' -> ') }
             .to_h
  end

  def insertion(polymer)
    polymer.chars.reduce do |result, ch|
      rule = rules[result[-1] + ch]
      rule ? result + rule + ch : result + ch
    end
  end
end
day14 = Day14.new(ARGF.map(&:chomp).freeze)
p part1: day14.part1
p part2: day14.part2
