#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'lazy_priority_queue'

class AmphipodState
  attr_reader :spaces, :rooms, :rownums

  # spaces[space{11}]
  #
  # 0123456789A

  # rooms[[0], [1], [2], [3]]:
  #   TopA BotA
  #   TopB BotB
  #   TopC BotC
  #   TopD BotD

  def inspect
    "<#{self.class} rooms='\n#############\n" \
      '#' + spaces.map { |ch| ch || '.' }.join('') + "#\n" +
      rownums.map do |row|
        (row.zero? ? '###' : '  #') +
          rooms.map { |rcol| rcol[row] || '.' }.join('#') +
          (row.zero? ? '###' : '#')
      end.join("\n") +
      "\n  #########\n' heuristic=#{heuristic_cost}>"
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

  def solved?
    heuristic_cost.zero?
  end

  def self.init_from(rooms)
    new(Array.new(11).freeze, rooms.transpose.freeze)
  end

  def heuristic_cost
    # will be <= the actual cost
    heuristic_from_rooms + heuristic_from_hall + heuristic_to_home
  end

  private

  COLS = (0..3).to_a.freeze
  def heuristic_from_rooms
    sum = 0
    COLS.each do |col|
      start_col = 2 * (col + 1)
      rcol = rooms[col]
      rownums.each do |row|
        type = rcol[row]
        next unless type

        tcol = TYPE_COL[type]
        next if col == tcol

        desired_col = 2 * (tcol + 1)

        # cost to go back down is separate
        up_moves = row + 1
        side_moves = (start_col - desired_col).abs
        min_moves = up_moves + side_moves

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
      # cost to go back down is separate
      min_moves = (col - desired_col).abs
      sum += (min_moves * COSTS[type])
    end
    sum
  end

  def heuristic_to_home
    sum = 0
    TYPE_COL.each do |type, col|
      rcol = rooms[col]
      rownums.each do |row|
        next if type == rcol[row]

        down_moves = row + 1
        sum += (down_moves * COSTS[type])
      end
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
      rcol = rooms[col]
      rownums.each do |row|
        type = rcol[row]

        # nobody here:
        next unless type
        # i'm blocked in:
        next unless rownums.all? do |rnum|
          rnum >= row || rcol[rnum].nil?
        end

        # i'm already home:
        if col == TYPE_COL[type] && rownums.all? do |rnum|
             rnum <= row || rcol[rnum] == type
           end
          next
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
    type = rooms[col][row]
    rooms_copy = rooms.map(&:dup)
    spaces_copy = spaces.dup

    rooms_copy[col][row] = nil
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

    dcol = rooms_copy[desired_col]
    index = rownums.select { |row| dcol[row].nil? }.max
    dcol[index] = type
    moves_count += index + 1

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
    rcol = rooms[TYPE_COL[type]]
    rcol.all? { |t| t == type || t.nil? }
  end

  def initialize(spaces, rooms)
    @spaces = spaces.freeze
    @rooms = rooms.map(&:freeze).freeze
    @rownums = (0...rooms[0].length).to_a.freeze
  end
end

class Day23
  def part1
    self.class.a_star(amphipods_init)
  end

  def part2
    self.class.a_star(amphipods_extended_init)
  end

  private

  attr_reader :amphipods_init, :amphipods_extended_init

  EFFECTIVE_INFINITY = 1 << 63
  def self.a_star(start)
    scores = Hash.new(EFFECTIVE_INFINITY)
    scores[start] = 0

    fScore = MinPriorityQueue.new
    fScore.push start, 0 + start.heuristic_cost

    iter = 0
    until fScore.empty?
      current = fScore.pop
      curr_score = scores[current]

      if current.solved?
        raise StandardError if start.heuristic_cost > curr_score

        return curr_score
      end

      current.moves.each do |neighbor, dist|
        tentative_score = curr_score + dist
        next unless tentative_score < scores[neighbor]

        new_score = tentative_score + neighbor.heuristic_cost
        if scores[neighbor] == EFFECTIVE_INFINITY
          fScore.push neighbor, new_score
        else
          fScore.decrease_key neighbor, new_score
        end
        scores[neighbor] = tentative_score
      end
    end

    :failure
  end

  def self.rooms_from(lines)
    lines
      .drop(2)
      .take_while { |line| !line.start_with?('  ###') }
      .map do |line|
        rms = line.gsub(' ', '').gsub('#', '')
        rms.chars.map do |ch|
          case ch
          when '.'
            nil
          else
            ch
          end
        end
      end
  end

  def initialize(lines)
    rooms = self.class.rooms_from(lines)
    @amphipods_init = AmphipodState.init_from(rooms)
    rooms.insert(1, 'DCBA'.chars, 'DBAC'.chars)
    @amphipods_extended_init = AmphipodState.init_from(rooms)
  end
end

day23 = Day23.new(ARGF.map(&:chomp).freeze)
p part1: day23.part1
p part2: day23.part2
