#!/usr/bin/env ruby

require 'set'

class Day8
  NUMERALS = [
    [0, 1, 2, 4, 5, 6].freeze,
    [2, 5].freeze,
    [0, 2, 3, 4, 6].freeze,
    [0, 2, 3, 5, 6].freeze,
    [1, 2, 3, 5].freeze,
    [0, 1, 3, 5, 6].freeze,
    [0, 1, 3, 4, 5, 6].freeze,
    [0, 2, 5].freeze,
    [0, 1, 2, 3, 4, 5, 6].freeze,
    [0, 1, 2, 3, 5, 6].freeze
  ].freeze
  UNIQUE_LENGTHS = NUMERALS
                   .map(&:length)
                   .tally
                   .select { |_, c| c == 1 }
                   .map(&:first)
                   .to_set
                   .freeze
  POSSIBLE_PERMUTATIONS = 'abcdefg'
                          .chars
                          .permutation
                          .map do |perm|
    NUMERALS.map { |segments| perm.values_at(*segments).sort.join.freeze }.freeze
  end
                          .freeze

  attr_reader :list

  def initialize(lines)
    @list = lines
            .map(&:chomp)
            .map do |item|
      item
        .split(' | ')
        .map do |sec|
          sec
            .split(' ')
            .map { |digit| digit.chars.sort.join }.freeze
        end.freeze
    end.freeze
  end

  def part1
    list.sum do |_, output|
      output.count { |digit| UNIQUE_LENGTHS.include? digit.length }
    end
  end

  def part2
    list.sum { |patterns, output| decode(patterns, output) }
  end

  private

  def decode(patterns, output)
    h = deduce(patterns)
    numerals = output.map { |num| h.find_index(num) }
    numerals.join.to_i
  end

  def deduce(patterns)
    patterns = patterns.to_set
    POSSIBLE_PERMUTATIONS
      .select do |would_be|
        patterns.include?(would_be[1]) &&
          patterns.include?(would_be[4]) &&
          patterns.include?(would_be[7])
      end
      .select { |would_be| (patterns ^ would_be).empty? }
      .first
  end
end

day8 = Day8.new(ARGF)
p :part1, day8.part1
p :part2, day8.part2
