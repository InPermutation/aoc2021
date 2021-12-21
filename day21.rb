#!/usr/bin/env ruby
# frozen_string_literal: true

class Day21
  SCORE_STARTS = 0
  ROLLS_STARTS = 0
  DIE_STARTS = 1
  DIE_ENDS = 100
  BOARD_STARTS = 1
  BOARD_ENDS = 10

  def part1
    state = GameState.new(
      Player.new(p1_start, SCORE_STARTS, 'Player 1'),
      Player.new(p2_start, SCORE_STARTS, 'Player 2'),
      DIE_STARTS,
      ROLLS_STARTS
    )

    state = turn(state) while state.next_player.score < 1000

    [state.current_player.score, state.next_player.score].min * state.total_roll_count
  end

  def part2
    state = GameState.new(
      Player.new(p1_start, SCORE_STARTS, 'Player 1'),
      Player.new(p2_start, SCORE_STARTS, 'Player 2'),
      DIE_STARTS,
      ROLLS_STARTS
    )
    dirac(state).values.max
  end

  private

  Player = Struct.new(:position, :score, :name)
  GameState = Struct.new(:current_player, :next_player, :next_roll, :total_roll_count)

  def modulo(value, min, max)
    (value - min) % max + min
  end

  def turn(state)
    name = state.current_player.name
    rolls = 4.times.reduce([state.next_roll]) do |r, _|
      next_roll = modulo(r.last + 1, DIE_STARTS, DIE_ENDS)
      r.push(next_roll)
    end

    printf "#{name} rolls #{rolls.take(3).map(&:to_s).join('+')}"
    sum = rolls.take(3).sum
    dest = modulo(state.current_player.position + sum, BOARD_STARTS, BOARD_ENDS)
    printf " and moves to space #{dest}"
    new_score = state.current_player.score + dest
    printf " for a total score of #{new_score}."
    puts

    GameState.new(state.next_player, Player.new(dest, new_score, name), rolls[3], state.total_roll_count + 3)
  end

  def key(state)
    [
      state.current_player.name,
      state.current_player.position,
      state.current_player.score,
      state.next_player.position,
      state.next_player.score
    ]
  end

  DIRAC_DIE_STARTS = 1
  DIRAC_DIE_ENDS = 3
  DIRAC_WIN_CONDITION = 21
  DIRAC_RANGE = Range.new(DIRAC_DIE_STARTS, DIRAC_DIE_ENDS).to_a.freeze
  DIRAC_ROLLS = DIRAC_RANGE.product(DIRAC_RANGE).product(DIRAC_RANGE).map(&:flatten).freeze

  def dirac(state)
    wins[key(state)] ||= DIRAC_ROLLS.reduce(Hash.new(0)) do |iwin, rolls|
      name = state.current_player.name
      sum = rolls.take(3).sum
      dest = modulo(state.current_player.position + sum, BOARD_STARTS, BOARD_ENDS)
      new_score = state.current_player.score + dest
      subscore = if new_score >= DIRAC_WIN_CONDITION
                   {name => 1}
                 else
                   dirac(
                     GameState.new(
                       state.next_player,
                       Player.new(dest, new_score, name),
                       -1,
                       -1
                     )
                   )
                 end
      iwin.merge(subscore) { |_key, old, new| old + new }
    end
  end

  attr_reader :p1_start, :p2_start
  attr_reader :wins

  def initialize(lines)
    raise NotImplementedError unless lines.length == 2

    @p1_start = lines[0].delete_prefix('Player 1 starting position: ').to_i
    @p2_start = lines[1].delete_prefix('Player 2 starting position: ').to_i
    @wins = {}
  end
end

day21 = Day21.new(ARGF.map(&:chomp).freeze)
p part1: day21.part1
p part2: day21.part2
