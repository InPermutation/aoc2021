#!/usr/bin/env ruby

require 'set'

class Day8
  NUMERALS = [
    [0, 1, 2, 4, 5, 6],
    [2, 5],
    [0, 2, 3, 4, 6],
    [0, 2, 3, 5, 6],
    [1, 2, 3, 5],
    [0, 1, 3, 5, 6],
    [0, 1, 3, 4, 5, 6],
    [0, 2, 5],
    [0, 1, 2, 3, 4, 5, 6],
    [0, 1, 2, 3, 5, 6]
  ]

  attr_reader :list
  def initialize(lines)
    @list = lines
      .map(&:chomp)
      .map { |item|
        item
          .split(' | ')
          .map { |sec|
            sec
              .split(' ')
              .map { |digit| digit.chars.sort.join }
          }
      }
  end

  def part1
    list.sum { |_, output|
      output.count { |digit| [2, 3, 4, 7].include? digit.length }
    }
  end

  def part2
    list.sum { |patterns, output| decode(patterns, output) }
  end

  def decode(patterns, output)
    h = deduce(patterns)
    numerals = output.map { |num| h.find_index(num) }
    numerals.join.to_i
  end

  def deduce(patterns)
    patterns = patterns.to_set
    'abcdefg'
      .chars
      .permutation
      .map { |perm|
        NUMERALS.map { |segments| segments.map { |seg| perm[seg] }.sort.join }
      }
      .select { |would_be| would_be.to_set == patterns }
      .first
  end
end

day8 = Day8.new(ARGF)
p :part1, day8.part1
p :part2, day8.part2
