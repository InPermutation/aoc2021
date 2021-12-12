#!/usr/bin/env ruby
# frozen_string_literal: true

class Day12
  def part1
    ans = paths(['start']) do |route|
      route
        .select(&method(:small?))
        .tally
        .values
        .max < 2
    end
    ans.length
  end

  def part2
    ans = paths(['start']) do |route|
      route
        .select(&method(:small?))
        .tally
        .values
        .map(&:pred)
        .select(&:positive?)
        .sum <= 1
    end
    ans.length
  end

  private

  attr_reader :edges

  def initialize(lines)
    @edges = lines.map { _1.split('-') }
  end

  def paths(route, &block)
    return [route] if route.last == 'end'

    neighbors(route.last)
      .map { |cave| route.dup.push(cave) }
      .select { |proposed_route| block.yield proposed_route }
      .flat_map { |proposed_route| paths(proposed_route, &block) }
  end

  def neighbors(from)
    potentials =
      edges.select { |pair| pair.first == from }.map(&:last) +
      edges.select { |pair| pair.last == from }.map(&:first)
    potentials.reject { |cave| cave == 'start' }
  end

  def small?(cave)
    cave.downcase == cave
  end
end
lines = ARGF.map(&:chomp).freeze
day12 = Day12.new(lines.dup)

p part1: day12.part1
p part2: day12.part2
