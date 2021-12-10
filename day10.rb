#!/usr/bin/env ruby
# frozen_string_literal: true

class Day10
  SYNTAX_ERROR_SCORE = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137
  }.freeze
  CHUNK_PAIRS = {
    '(' => ')',
    '[' => ']',
    '{' => '}',
    '<' => '>'
  }.freeze

  def part1
    errs = lines
      .map(&method(:first_error))
      .compact
      .map(&SYNTAX_ERROR_SCORE.method(:[]))
      .sum
  end

  private

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end

  def first_error(line)
    stack = []
    line.chars.each do |ch|
      if CHUNK_PAIRS.include?(ch)
        stack.push(ch)
      elsif stack.empty?
        # incomplete
        return
      elsif CHUNK_PAIRS[stack.pop] == ch
        next
      else
        # err
        return ch
      end
    end
    # all ok
    return
  end
end

day10 = Day10.new(ARGF.map(&:chomp))
p :part1, day10.part1
