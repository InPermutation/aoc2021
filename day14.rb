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
    return polymer.chars.tally.freeze if depth.zero?

    k = "#{' ' * depth}#{polymer}"
    @memo[k] ||= unmemoized_tally_for(polymer, depth)
  end

  def unmemoized_tally_for(polymer, depth)
    polymer
      .chars
      .each_cons(2)
      .map { |a, b| tally_pair(a, b, depth) }
      .reduce(&method(:merge_tally))
      .tap { |t| t[polymer[-1]] += 1 }
      .freeze
  end

  def tally_pair(left, right, depth)
    production = rules[left + right]
    tally_for(left + production + right, depth - 1)
      .dup
      .tap { |t| t[right] -= 1 }
      .freeze
  end

  def merge_tally(tally, curr)
    tally.merge(curr) { |_key, lval, rval| [lval, rval].compact.sum }
  end
end

day14 = Day14.new(ARGF.map(&:chomp).freeze)
p part1: day14.part1
p part2: day14.part2
