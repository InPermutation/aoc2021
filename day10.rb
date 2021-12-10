#!/usr/bin/env ruby
# frozen_string_literal: true

class Day10
  SYNTAX_ERROR_SCORE = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137
  }.freeze

  AUTOCOMPLETE_SCORE = {
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4
  }.freeze

  CHUNK_PAIRS = {
    '(' => ')',
    '[' => ']',
    '{' => '}',
    '<' => '>'
  }.freeze

  def part1
    lines
      .map(&method(:syntax_check))
      .select(&method(:corrupt?))
      .map(&method(:syntax_error_score))
      .sum
  end

  def part2
    scores = lines
      .map(&method(:syntax_check))
      .select(&method(:incomplete?))
      .map(&method(:autocomplete_score))

    # the winner is found by sorting all of the scores
    # and then taking the middle score
    scores.sort[scores.length / 2]
  end

  private

  attr_reader :lines

  def initialize(lines)
    @lines = lines.freeze
  end

  def syntax_check(line)
    stack = []
    line.chars.each do |ch|
      if CHUNK_PAIRS.include?(ch)
        stack.push(ch)
      elsif stack.empty?
        return [:underflow, ch, stack]
      elsif CHUNK_PAIRS[stack.pop] == ch
        next
      else
        return [:corrupt, ch]
      end
    end
    if stack.empty?
      return [:complete]
    else
      return [:incomplete, stack]
    end
  end

  def underflow?(state)
    state[0] == :underflow
  end

  def corrupt?(state)
    state[0] == :corrupt
  end

  def compete?(state)
    state[0] == :complete
  end

  def incomplete?(state)
    state[0] == :incomplete
  end

  def syntax_error_score(state)
    case state
      in [:corrupt, wrong]
        SYNTAX_ERROR_SCORE[wrong]
    end
  end

  def autocomplete_score(state)
    case state
      in [:incomplete, stack]
        stack
          .reverse
          .map { AUTOCOMPLETE_SCORE[CHUNK_PAIRS[_1]] }
          .reduce(0) { |total, point_value| total * 5 + point_value }
    end
  end
end

day10 = Day10.new(ARGF.map(&:chomp))
p :part1, day10.part1
p :part2, day10.part2
