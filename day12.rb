#!/usr/bin/env ruby
# frozen_string_literal: true

class Day12
  def part1
    paths.length
  end

  def part2
  end

  private

  attr_reader :edges

  def initialize(lines)
    @edges = lines.map { _1.split('-') }
  end

  def paths(route=nil)
    route ||= ['start']

    return [route] if route.last == 'end'

    neighbors(route.last)
      .reject { |cave| cave == 'start' }
      .reject { |cave| small?(cave) && route.include?(cave) }
      .flat_map { |cave| paths(route.dup.push(cave)) }
  end

  def neighbors(from)
    edges.select { |pair| pair.first == from }.map { |pair| pair.last } +
      edges.select { |pair| pair.last == from }.map { |pair| pair.first }
  end

  def small?(cave)
    cave.downcase == cave
  end
end
lines = ARGF.map(&:chomp).freeze
day12 = Day12.new(lines.dup)

p part1: day12.part1
p part2: day12.part2
