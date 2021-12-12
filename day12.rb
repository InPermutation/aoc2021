#!/usr/bin/env ruby
# frozen_string_literal: true

class Route
  attr_reader :last, :small_tally

  private

  def initialize(prev_route, cave)
    @last = cave
    @small_tally = prev_route&.small_tally&.dup || Hash.new(0)
    @small_tally[cave] += 1 if small?(cave)
    @small_tally = @small_tally.freeze
  end

  def small?(cave)
    cave.downcase == cave
  end
end

class Day12
  def part1
    paths do |route|
      route
        .small_tally
        .values
        .max < 2
    end.length
  end

  def part2
    paths do |route|
      route
        .small_tally
        .values
        .map(&:pred)
        .select(&:positive?)
        .sum <= 1
    end.length
  end

  private

  attr_reader :neighbors

  def initialize(lines)
    h = Hash.new { |h, k| h[k] = [] }
    lines.map { _1.split('-') }.each do |a, b|
      h[a].push(b) unless b == 'start' || a == 'end'
      h[b].push(a) unless b == 'end' || a == 'start'
    end
    @neighbors = h.freeze
  end

  def paths(route = Route.new(nil, 'start'), &block)
    return [route] if route.last == 'end'

    neighbors[route.last]
      .map { |cave| Route.new(route, cave) }
      .select(&block)
      .flat_map { |proposed_route| paths(proposed_route, &block) }
  end
end
day12 = Day12.new(ARGF.map(&:chomp).freeze)
p part1: day12.part1
p part2: day12.part2
