#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

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
    tentative_distance = all_points.map { |pt| [pt, EFFECTIVE_INFINITY] }.to_h
    tentative_distance[initial_node] = 0
    unvisited_order = all_points.sort_by { |pt| tentative_distance[pt] }
    current_node = initial_node

    until unvisited.empty?
      my_distance = tentative_distance[current_node]
      neighbors(current_node)
        .select(&unvisited.method(:include?))
        .each do |unvisited_neighbor|
        proposed_distance = my_distance + costs[unvisited_neighbor]
        if proposed_distance < tentative_distance[unvisited_neighbor]
          unvisited_order.delete(unvisited_neighbor)
          ix = unvisited_order.bsearch_index { |o| tentative_distance[o] > proposed_distance }
          unvisited_order.insert(ix, unvisited_neighbor)

          tentative_distance[unvisited_neighbor] = proposed_distance
        end
      end

      unvisited.delete(current_node)
      current_node = unvisited_order.shift
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
