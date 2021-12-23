#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pmap'

class Cuboid
  # [xmin..xmax, ymin..ymax, zmin..zmax]
  attr_reader :ranges

  def fully_contains?(other)
    ranges.zip(other.ranges).all? do |rc1, rc2|
      rc1.begin <= rc2.begin && rc1.end >= rc2.end
    end
  end

  def inspect
    "<Cuboid[#{ranges[0]}, #{ranges[1]}, #{ranges[2]}]>"
  end

  def init_procedure?
    ranges.none? { |r| r.min < -50 || r.max > 50 }
  end

  def count
    ranges.map(&:count).reduce(&:*)
  end

  alias to_s inspect

  private

  def initialize(ranges)
    @ranges = ranges.freeze
  end
end

class Day22
  def part1
    init_commands = commands
                    .select { |_, cuboid| cuboid.init_procedure? }
    Day22.count_on(init_commands)
  end

  def part2
    Day22.count_on(commands)
  end

  private

  def self.disjoint(r1, r2)
    r1_min, r1_max = r1.minmax
    r2_min, r2_max = r2.minmax
    raise "misordered" if r1_min > r2_min
    raise "don't intersect" if r1_max < r2_min

    if r1 == r2
      return [r1]
    end
    if r1_min == r2_min
      minmax = [r2_max, r1_max].minmax
      smol = Range.new(r1_min, minmax.min)
      lg = Range.new(minmax.min + 1, minmax.max)
      return [smol, lg]
    end
    if r1_max > r2_max
      return [Range.new(r1_min, r2_min - 1), r2, Range.new(r2_max + 1, r1_max)]
    end
    if r1_max == r2_max
      return [Range.new(r1_min, r2_min - 1), r2]
    end

    return [Range.new(r1_min, r2_min - 1),
            Range.new(r2_min, r1_max),
            Range.new(r1_max + 1, r2_max)]
  end

  def self.range_combined(ranges)
    has_replaced = true

    while has_replaced do
      has_replaced = false

      ranges = ranges.sort_by(&:minmax)

      i = 0
      while i < ranges.length - 1
        if ranges[i + 1].min <= ranges[i].max
          replacements = disjoint(ranges[i], ranges[i+1])
          ranges.delete_at(i + 1)
          ranges.delete_at(i)
          ranges.insert(i, *replacements)
          has_replaced = true
          break
        end
        i += 1
      end
    end
    ranges
  end

  def self.sectors(cmds)
    cxr, cyr, czr = (0..2).pmap { |i|
      range_combined(cmds.map { |cmd| cmd[1].ranges[i] })
    }
    puts cxr.length
    puts cyr.length
    puts czr.length
    @product = cxr.length * cyr.length * czr.length
    p product: @product
    Enumerator.new do |y|
      for xr in cxr
        for yr in cyr
          for zr in czr
            cub = Cuboid.new([xr, yr, zr])
            y << cub
          end
        end
      end
    end
  end

  def self.lit?(sector, cmds)
    cmds.reduce(false) do |lit, command|
      cmd, cuboid = command
      is_contained = cuboid.fully_contains?(sector)

      if is_contained
        case cmd
        when 'on'
          true
        when 'off'
          false
        end
      else
        lit
      end
    end
  end

  def self.count_on(cmds)
    vals = sectors(cmds).pmap { |sector|
      lit?(sector, cmds) ? sector.count : 0
    }
    vals.sum
  end

  attr_reader :commands

  def initialize(lines)
    @commands = lines
                .map do |line|
      cmd, rangestr = line.split(' ', 2)

      rangecube = rangestr
                  .split(',')
                  .map do |range|
        _axis, range = range.split('=')
        Range.new(*range.split('..').map(&:to_i))
      end

      [cmd.freeze, Cuboid.new(rangecube)].freeze
    end.to_a.freeze
  end
end

def assert_equal(expected, actual)
  raise "assert_equal:\n#{expected} !=\n#{actual}" unless expected == actual
end
assert_equal [9..9, 10..10, 11..11, 12..12, 13..13],
  Day22.range_combined([9..11, 10..12, 10..10, 11..13])
assert_equal [10..19, 20..20, 21..30],
  Day22.disjoint(10..20, 20..30)
assert_equal [10..20, 21..30],
  Day22.disjoint(10..20, 10..30)
assert_equal [0..99, 100..150, 151..200],
  Day22.disjoint(0..150, 100..200)
assert_equal [0..99, 100..200, 201..300],
  Day22.disjoint(0..300, 100..200)

day22 = Day22.new(ARGF.map(&:chomp).freeze)
p part1: day22.part1
p part2: day22.part2
