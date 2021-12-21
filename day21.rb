#!/usr/bin/env ruby
# frozen_string_literal: true

class Day21
  SCORE_STARTS = 0
  DIE_STARTS = 1
  DIE_ENDS = 100
  BOARD_STARTS = 1
  BOARD_ENDS = 10

  def part1
    state = initial_state
    rolls = (DIE_STARTS..DIE_ENDS).to_a
    count = 0
    while state.next_player.score < 1000
      state = GameState.new(state.next_player, move(state.current_player, rolls))
      rolls.rotate!(3)
      count += 3
    end

    [state.current_player.score, state.next_player.score].min * count
  end

  def part2
    dirac(initial_state).values.max
  end

  private

  Player = Struct.new(:position, :score, :name)
  GameState = Struct.new(:current_player, :next_player)

  def initial_state
    GameState.new(
      Player.new(p1_start, SCORE_STARTS, 'Player 1'),
      Player.new(p2_start, SCORE_STARTS, 'Player 2')
    )
  end

  def modulo(value, min, max)
    (value - min) % max + min
  end

  def move(player, rolls)
    name = player.name
    sum = rolls.take(3).sum
    dest = modulo(player.position + sum, BOARD_STARTS, BOARD_ENDS)
    new_score = player.score + dest
    Player.new(dest, new_score, name)
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
      moved_player = move(state.current_player, rolls)
      subscore = if moved_player.score >= DIRAC_WIN_CONDITION
                   { moved_player.name => 1 }
                 else
                   dirac(GameState.new(state.next_player, moved_player))
                 end
      iwin.merge(subscore) { |_key, old, new| old + new }
    end
  end

  attr_reader :p1_start, :p2_start, :wins

  def initialize(lines)
    raise NotImplementedError unless lines.length == 2

    @p1_start = lines[0].delete_prefix('Player 1 starting position: ').to_i
    @p2_start = lines[1].delete_prefix('Player 2 starting position: ').to_i
    @wins = {}
  end
end

puts 'Tests '
test = Day21.new(['Player 1 starting position: 4',
                  'Player 2 starting position: 8'])
raise StandardError, 'part1 failed' unless test.part1 == 739_785
raise StandardError, 'part2 failed' unless test.part2 == 444_356_092_776_315

puts 'passed'

day21 = Day21.new(ARGF.map(&:chomp).freeze)
p part1: day21.part1
p part2: day21.part2
