#!/usr/bin/env ruby
# frozen_string_literal: true

class Day14
  def part1
    min, max = tally_for(template, 10).values.minmax
    max - min
  end

  def part2
    min, max = tally_for(template, 40).values.minmax
    max - min
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

  def tally_for(polymer, depth)
    return polymer.chars.tally.freeze if depth == 0

    k = "#{" " * depth}#{polymer}"
    return @memo[k] if @memo[k]

    t = polymer.chars.each_cons(2).map do |a, b|
      production = rules[a + b]
      t = tally_for(a + production + b, depth - 1).dup
      t[b] -= 1
      t
    end.reduce do |tally, curr|
      tally.merge(curr) { |_key, lval, rval| [lval, rval].compact.sum }
    end
    t[polymer.chars.last] += 1
    @memo[k] = t.freeze
  end
end
day14 = Day14.new(ARGF.map(&:chomp).freeze)
p part1: day14.part1
p part2: day14.part2
