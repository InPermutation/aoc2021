#!/usr/bin/env ruby
# frozen_string_literal: true

class Cuboid
  # [xmin..xmax, ymin..ymax, zmin..zmax]
  attr_reader :ranges

  def intersect?(other)
    myranges = ranges
    oranges = other.ranges
    rc1 = myranges[0]
    rc2 = oranges[0]
    return false unless rc1.end >= rc2.begin && rc1.begin <= rc2.end
    rc1 = myranges[1]
    rc2 = oranges[1]
    return false unless rc1.end >= rc2.begin && rc1.begin <= rc2.end
    rc1 = myranges[2]
    rc2 = oranges[2]
    return false unless rc1.end >= rc2.begin && rc1.begin <= rc2.end

    return true
  end

  def fully_contains?(other)
    myranges = ranges
    oranges = other.ranges
    rc1 = myranges[0]
    rc2 = oranges[0]
    return false unless rc1.begin <= rc2.begin && rc1.end >= rc2.end
    rc1 = myranges[1]
    rc2 = oranges[1]
    return false unless rc1.begin <= rc2.begin && rc1.end >= rc2.end
    rc1 = myranges[2]
    rc2 = oranges[2]
    return false unless rc1.begin <= rc2.begin && rc1.end >= rc2.end

    return true
  end

  def inspect
    "<Cuboid[#{ranges[0]}, #{ranges[1]}, #{ranges[2]}]>"
  end

  def init_procedure?
    ranges.none? { |r| r.begin < -50 || r.end > 50 }
  end

  def except(other)
    what = ranges
           .zip(other.ranges)
           .map(&Cuboid.method(:possibly))

    intersection = what[0].product(*what.drop(1))
    while intersection.delete(other.ranges); end
    cuboids = intersection
              .map { |rangecube| Cuboid.new(rangecube) }
              .to_a
  end

  def self.possibly(range2)
    my_range, their_range = range2
    my_begin = my_range.begin
    my_end = my_range.end
    their_begin = their_range.begin
    their_end = their_range.end
    if my_end < their_begin || my_begin > their_end
      raise "err possibly #{range2}"
    elsif my_begin < their_begin && my_end > their_end
      legal_ranges((my_begin..(their_begin - 1)), their_range, (their_end + 1)..my_end)
    elsif my_begin >= their_begin && my_end <= their_end
      [my_range]
    elsif my_begin < their_begin
      legal_ranges((my_begin..(their_begin - 1)), (their_begin..my_end))
    elsif my_end >= their_end
      legal_ranges((my_begin..their_end), ((their_end + 1)..my_end))
    else
      raise 'oh no'
    end
  end

  def self.legal_ranges(*ranges)
    ranges.select { _1.begin <= _1.end }
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
    Day22.execute(init_commands).sum(&:count)
  end

  def part2
    Day22.execute(commands).sum(&:count)
  end

  private

  def self.execute(cmds)
    i = 0

    cmds.reduce([]) do |on_cuboids, command|
      puts "execute #{command} (#{i += 1}/#{cmds.length}) (on_cuboids.length = #{on_cuboids.length})"
      cmd, cuboid = command
      case cmd
      when 'on'
        on_cuboids = switch_on(on_cuboids, cuboid)
      when 'off'
        on_cuboids = switch_off(on_cuboids, cuboid)
      end
    end
  end

  def self.switch_on(on_cuboids, *cuboids)
    on_cuboids.each do |already_on|
      cuboids = cuboids.reject(&already_on.method(:fully_contains?))
      cuboids.each do |to_switch|
        next unless already_on.intersect?(to_switch)
        raise 'whoops' unless cuboids.delete(to_switch)

        cuboids += to_switch.except(already_on)
        return switch_on(on_cuboids, *cuboids)
      end
    end
    on_cuboids + cuboids
  end

  def self.switch_off(on_cuboids, cuboid)
    on_cuboids.each do |already_on|
      next unless cuboid.intersect?(already_on)
      raise 'whoops' unless on_cuboids.delete(already_on)

      on_cuboids += already_on.except(cuboid) unless cuboid.fully_contains?(already_on)
      return switch_off(on_cuboids, cuboid)
    end
    on_cuboids
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

day22 = Day22.new(ARGF.map(&:chomp).freeze)
p part1: day22.part1
p part2: day22.part2
