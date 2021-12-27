#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'lazy_priority_queue'

class AmphipodState
  attr_reader :spaces, :rooms
  # spaces[space{11}]
  #
  # 0123456789A

  # rooms[[top], [bottom]]:
  #   0 1 2 3
  #   0 1 2 3

  def inspect
    "<#{self.class} rooms='\n#############\n" +
      "#" + spaces.map { |ch| ch || '.' }.join('') + "#\n" +
      "###" + rooms[0].map { |ch| ch || '.' }.join('#') + "###\n" +
      "  #" + rooms[1].map { |ch| ch || '.' }.join('#') + "#\n" +
      "  #########\n' heuristic=#{heuristic_cost}>"
  end
  alias to_s inspect

  def ==(other)
    spaces == other.spaces && rooms == other.rooms
  end
  alias eql? ==

  def hash
    spaces.hash ^ rooms.hash
  end

  def moves
    # Amphipods will never move from the hallway into a room
    # Therefore, there are only 2 kinds of moves that are possible:
    #  * An amphipod moves out into an empty space in the hallway.
    #  * An amphipod moves from the hallway into its destination room.
    moves_out + moves_home
  end

  TARGET_SOLUTION = [['A', 'B', 'C', 'D'].freeze,
                     ['A', 'B', 'C', 'D'].freeze].freeze
  def solved?
    return false unless spaces.compact.empty?
    return false unless rooms == TARGET_SOLUTION
    return true
  end

  def self.init_from(rooms)
    new(Array.new(11).freeze, rooms.freeze)
  end

  def heuristic_cost
    # will be <= the actual cost
    heuristic_from_rooms + heuristic_from_hall
  end

  private

  COLS = (0..3).to_a.freeze
  ROWS = (0..1).to_a.freeze
  def heuristic_from_rooms
    sum = 0
    COLS.each do |col|
      start_col = 2 * (col + 1)
      ROWS.each do |row|
        type = rooms[row][col]
        next unless type

        tcol = TYPE_COL[type]
        next if col == tcol

        desired_col = 2 * (tcol + 1)
        min_moves = (start_col - desired_col).abs + 1 + row + 1
        sum += (min_moves * COSTS[type])
      end
    end
    sum
  end

  def heuristic_from_hall
    sum = 0
    spaces.each.with_index do |type, col|
      next unless type

      desired_col = 2 * (TYPE_COL[type] + 1)
      min_moves = (col - desired_col).abs + 1
      sum += (min_moves * COSTS[type])
    end
    sum
  end

  COSTS = {
    'A' => 1,   # Amber
    'B' => 10,  # Bronze
    'C' => 100, # Copper
    'D' => 1000 # Desert
  }.freeze
  HALLS = [2, 4, 6, 8].freeze
  def moves_out
    # Amphipods will never stop on the space immediately outside any room.
    mout = []

    COLS.each do |col|
      ROWS.each do |row|
        type = rooms[row][col]

        # nobody here:
        next unless type
        # i'm blocked in:
        next unless row == 0 || rooms[0][col].nil?
        # i'm already home:
        if col == TYPE_COL[type]
          next if row == 1
          next if row == 0 && rooms[1][col] == type
        end

        start_col = 2 * (col + 1)
        reachable(start_col).each do |open_col|
          next if HALLS.include?(open_col)
          mout << move_one_out(row, col, start_col, open_col)
        end
      end
    end
    mout
  end

  def reachable(start_col)
    allowed_spaces = spaces.map.with_index.to_a
    to_left = allowed_spaces
      .reverse
      .drop_while { |_space, ix| ix >= start_col }
      .take_while { |space, _ix| space.nil? }
      .reverse
    to_right = allowed_spaces
      .drop_while { |_space, ix| ix <= start_col }
      .take_while { |space, _ix| space.nil? }
    (to_left + to_right)
      .map { |_nil, col| col }
  end

  def move_one_out(row, col, start_col, open_col)
    type = rooms[row][col]
    rooms_copy = rooms.map(&:dup)
    spaces_copy = spaces.dup

    rooms_copy[row][col] = nil
    spaces_copy[open_col] = type

    moves_count = (row + 1) + (start_col - open_col).abs
    cost = moves_count * COSTS[type]

    [self.class.new(spaces_copy, rooms_copy), cost]
  end

  def move_one_home(type, col, desired_home)
    cost_basis = COSTS[type]
    rooms_copy = rooms.map(&:dup)
    spaces_copy = spaces.dup

    spaces_copy[col] = nil
    desired_col = TYPE_COL[type]

    moves_count = (desired_home - col).abs

    if rooms_copy[1][desired_col].nil?
      moves_count += 2
      rooms_copy[1][desired_col] = type
    else
      moves_count += 1
      rooms_copy[0][desired_col] = type
    end

    cost = moves_count * cost_basis

    [self.class.new(spaces_copy, rooms_copy), cost]
  end

  def moves_home
    r = []
    spaces.each.with_index do |type, col|
      next unless type
      next unless room_ready(type)

      desired_home = (TYPE_COL[type] + 1) * 2

      next unless reachable(col).any? do |target_col|
        target_col == desired_home
      end

      r << move_one_home(type, col, desired_home)
    end
    r
  end

  TYPE_COL = 'ABCD'.chars.map.with_index.to_h.freeze
  def room_ready(type)
    tcol = TYPE_COL[type]

    rooms[1][tcol].nil? ||
      (rooms[1][tcol] == type && rooms[0][tcol].nil?)
  end

  def initialize(spaces, rooms)
    @spaces = spaces.map(&:freeze).freeze
    @rooms = rooms.map(&:freeze).freeze
  end
end

class Day23
  def part1
    start = amphipods_init
    self.class.a_star(start)
  end

  def part2
  end

  attr_reader :amphipods_init

  private

  EFFECTIVE_INFINITY = 1<<63
  def self.a_star(start)
    scores = Hash.new(EFFECTIVE_INFINITY)
    scores[start] = 0

    fScore = MinPriorityQueue.new
    fScore.push start, 0 + start.heuristic_cost

    iter = 0
    while !fScore.empty?
      current = fScore.pop
      curr_score = scores[current]

      if (iter += 1) % 1000 == 0
        puts current
        puts "(#{curr_score})"
        p gLen: scores.length, fLen: fScore.length
      end

      return curr_score if current.solved?

      current.moves.each do |neighbor, dist|
        tentative_score = curr_score + dist
        if tentative_score < scores[neighbor]
          new_score = tentative_score + neighbor.heuristic_cost

          if scores[neighbor] == EFFECTIVE_INFINITY
            fScore.push neighbor, new_score
          else
            fScore.decrease_key neighbor, new_score
          end
          scores[neighbor] = tentative_score

        end
      end
    end

    return :failure
  end


  def initialize(lines)
    rooms = lines
      .drop(2)
      .take(2)
      .map { |line| line.gsub(/[^ABCD]/, '').chars.freeze }
      .freeze
    @amphipods_init = AmphipodState.init_from(rooms)
  end
end

day23 = Day23.new(ARGF.map(&:chomp).freeze)
p part1: day23.part1
puts "(must be >= #{day23.amphipods_init.heuristic_cost})"
puts "(19198 is too high for INPUT)"
p part2: day23.part2
