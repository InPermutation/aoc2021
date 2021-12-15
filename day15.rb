#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'lazy_priority_queue'

class Day15
  def part1
    weights = dijkstras([0, 0])
    weights[[max_x, max_y]]
  end

  def part2
  end

  private

  EFFECTIVE_INFINITY = 1 << 64
  def dijkstras(initial_node)
    unvisited = Set.new(all_points)
    unvisited_pq = MinPriorityQueue.new
    tentative_distance = all_points.map { |pt| [pt, pt == initial_node ? 0 : EFFECTIVE_INFINITY] }.to_h
    tentative_distance.each { |pt, d| unvisited_pq.push(pt, d) }

    until unvisited.empty?
      current_node = unvisited_pq.pop
      unvisited.delete(current_node)
      my_distance = tentative_distance[current_node]
      neighbors(current_node)
        .select(&unvisited.method(:include?))
        .each do |unvisited_neighbor|
        proposed_distance = my_distance + costs[unvisited_neighbor]
        if proposed_distance < tentative_distance[unvisited_neighbor]
          unvisited_pq.decrease_key(unvisited_neighbor, proposed_distance)
          tentative_distance[unvisited_neighbor] = proposed_distance
        end
      end
    end
    tentative_distance
  end

  POSSIBLE_DIFFS = [[-1, 0], [1, 0], [0, -1], [0, 1]].freeze
  def neighbors(node)
    x, y = node
    POSSIBLE_DIFFS
      .map { |dx, dy| [x + dx, y + dy].freeze }
      .reject { |nx, ny| nx.negative? || ny.negative? || nx > max_x || ny > max_y }
  end

  attr_reader :costs, :max_x, :max_y, :all_points

  def initialize(lines)
    @costs = lines.flat_map.with_index do |line, y|
      line.chars.map.with_index { |str, x| [[x, y].freeze, str.to_i].freeze }
    end.to_h.freeze
    @all_points = @costs.keys.freeze
    @max_y = all_points.map(&:last).max
    @max_x = all_points.map(&:first).max
  end
end

day15 = Day15.new(ARGF.map(&:chomp).freeze)
p part1: day15.part1
p part2: day15.part2
