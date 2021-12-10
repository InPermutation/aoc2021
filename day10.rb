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
      .map(&method(:syntax_check))
      .select(&method(:corrupt?))
      .map { |_, wrong| SYNTAX_ERROR_SCORE[wrong] }
      .sum
  end

  private

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end

  def syntax_check(line)
    stack = []
    line.chars.each do |ch|
      if CHUNK_PAIRS.include?(ch)
        stack.push(ch)
      elsif stack.empty?
        return [:incomplete, stack]
      elsif CHUNK_PAIRS[stack.pop] == ch
        next
      else
        return [:corrupt, ch]
      end
    end
    return [:complete]
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
end

day10 = Day10.new(ARGF.map(&:chomp))
p :part1, day10.part1
