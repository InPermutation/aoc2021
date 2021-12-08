#!/usr/bin/env ruby
# frozen_string_literal: true

class Bingo
  attr_reader :draws, :boards

  def initialize(lines)
    @draws = lines.first.split(',').map(&:to_i)
    @boards = []
    lines.drop(1).each_slice(6) do |board|
      boards << Board.new(board.drop(1))
    end
  end

  def part1
    puts 'Part 1'
    draws.each do |call|
      boards.each { |board| board.play(call) }
      if b = boards.find(&:winner?)
        p b.sum * call
        break
      end
    end
  end

  def part2
    puts 'Part 2'
    last_winner = nil
    draws.each do |call|
      boards.each { |board| board.play(call) }
      losers = boards.reject(&:winner?)
      case losers.length
      when 1
        last_winner = losers.first
      when 0
        p last_winner.sum * call
        break
      end
    end
  end
end

class Board
  attr_reader :board

  WINRAR = Array.new(5).freeze

  def initialize(initial_board)
    @board = initial_board.map { |line| line.split.map(&:to_i) }
  end

  def play(call)
    board.each do |r|
      i = r.find_index(call)
      r[i] = nil if i
    end
  end

  def winner?
    # Rows:
    board.find { |r| r == WINRAR } ||
      board.length.times.find do |col|
        board.map { |r| r[col] } == WINRAR
      end
  end

  def sum
    board.flatten.compact.sum
  end
end

lines = ARGF.to_a.map(&:chomp)
Bingo.new(lines).part1
Bingo.new(lines).part2
