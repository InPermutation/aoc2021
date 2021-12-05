#!/usr/bin/env ruby

class Bingo
  attr_reader :draws, :boards
  def initialize(lines)
    @draws = lines.first.split(',').map(&:to_i)
    @boards = []
    lines.drop(1).each_slice(6) { |board|
      boards << Board.new(board.drop(1))
    }
  end

  def part1
    puts 'Part 1'
    for call in draws do
      boards.each { |board| board.play(call) }
      if b = boards.find { |board| board.winner? } then
        p b.sum * call
        break
      end
    end
  end
  
  def part2
    puts 'Part 2'
    last_winner = nil
    for call in draws do
      boards.each { |board| board.play(call) }
      losers = boards.reject(&:winner?)
      if losers.length == 1 then
        last_winner = losers.first
      elsif losers.length == 0 then
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
    board.each { |r|
	i = r.find_index(call)
        r[i] = nil if i
      }
  end

  def winner?
    # Rows:
    board.find { |r| r == WINRAR } ||
      board.length.times.find { |col|
        board.map { |r| r[col] } == WINRAR
      }
  end

  def sum
    board.flatten.compact.sum
  end
end

lines = ARGF.to_a.map(&:chomp)
Bingo.new(lines).part1
Bingo.new(lines).part2
