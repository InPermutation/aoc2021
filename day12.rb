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

  attr_reader :neighbors

  def initialize(lines)
    h = Hash.new
    lines.map { _1.split('-') }.each do |a, b|
      unless b == 'start' || a == 'end'
        h[a] ||= []
        h[a].push(b)
      end
      unless b == 'end' || a == 'start'
        h[b] ||= []
        h[b].push(a)
      end
    end
    @neighbors = h.freeze
  end

  def paths(route, &block)
    return [route] if route.last == 'end'

    neighbors[route.last]
      .map { |cave| route.dup.push(cave) }
      .select(&block)
      .flat_map { |proposed_route| paths(proposed_route, &block) }
  end

  def small?(cave)
    cave.downcase == cave
  end
end
lines = ARGF.map(&:chomp).freeze
day12 = Day12.new(lines.dup)

p part1: day12.part1
p part2: day12.part2
