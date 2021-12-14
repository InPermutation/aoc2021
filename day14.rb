#!/usr/bin/env ruby
# frozen_string_literal: true

class Day14
  def part1
    min, max = insertion(template, 10).chars.tally.values.minmax
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

    @memo = {}
  end

  def insertion(polymer, depth)
    return polymer if depth == 0

    k = "#{" " * depth}#{polymer}"
    return @memo[k] if @memo[k]

    t = polymer.chars.each_cons(2).map do |a, b|
      production = rules[a + b]
      t = insertion(a + production + b, depth - 1)
      t = t[0, t.length - 1]
    end.reduce do |tally, curr|
      tally + curr
    end
    t += polymer.chars.last
    @memo[k] = t
  end
end
day14 = Day14.new(ARGF.map(&:chomp).freeze)
p part1: day14.part1
p part2: day14.part2
