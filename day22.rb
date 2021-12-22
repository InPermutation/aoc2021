#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

class Day22
  def part1
    on = Set.new
    commands
      .select { |_, rangecube| init_procedure?(rangecube) }
      .each do |cmd, rangecube|
        points = all_points(*rangecube)
        case cmd
        when 'on'
          on.merge(points)
        when 'off'
          on.subtract(points)
        else
          raise StandardError, cmd
        end
      end
    on.length
  end

  def part2
    raise NotImplementedError, :part2
  end

  private

  def init_procedure?(rangecube)
    rangecube.none? { |r| r.min < -50 || r.max > 50 }
  end

  def all_points(xr, yr, zr)
    xr.to_a.product(yr.to_a, zr.to_a).map(&:freeze).freeze
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

        [cmd.freeze, rangecube.freeze].freeze
      end.to_a.freeze
  end
end

day22 = Day22.new(ARGF.map(&:chomp).freeze)
p part1: day22.part1
p part2: day22.part2
