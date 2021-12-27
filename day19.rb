#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'
require 'set'
require 'parallel'

class Day19
  def part1
    solved.flat_map(&:beacons).uniq.length
  end

  def part2
    offsets = solved
              .map(&:offset)
    offsets
      .product(offsets)
      .map { |v1, v2| (v1 - v2) }
      .map(&method(:manhattan_distance))
      .max
  end

  private

  def manhattan_distance(vector)
    vector.to_a.map(&:abs).sum
  end

  class Scanner
    attr_reader :name, :beacons, :offset

    BASES = [
      Vector.basis(size: 4, index: 0),
      Vector.basis(size: 4, index: 1),
      Vector.basis(size: 4, index: 2)
    ].freeze
    ORDERINGS = [0, 1, 2].permutation(3).to_a.uniq.freeze
    REFLECTIONS = [-1, 1].product([-1, 1]).product([-1, 1]).map(&:flatten).to_a.freeze
    ALL_ROTATIONS = ORDERINGS.product(REFLECTIONS).select do |orderings, reflections|
      bases = orderings.map(&BASES.method(:[]))
      arg = bases.zip(reflections).map { |bvec, rval| bvec * rval }
      cross = arg[0].cross(*arg.drop(1))
      cross[3] == 1
    end.freeze
    def possible_orientations
      ALL_ROTATIONS.map do |ordering, reflection|
        n = beacons.map do |b|
          bo = Vector.elements(b.to_a.values_at(*ordering))
          Vector.elements(bo.zip(reflection).map { |c, x| c * x })
        end
        Scanner.new(name, n)
      end
    end

    def with_offset(diff)
      n = beacons.map(&diff.method(:+))
      Scanner.new(name, n, diff)
    end

    def biggest_overlaps(other)
      possible_offsets = beacons.product(other.beacons).map { |s, u| s - u }
      possible_offsets.tally.max_by { |_diff, count| count }
    end

    private

    def initialize(name, beacons, offset = Vector[0, 0, 0])
      @name = name.freeze
      @beacons = beacons.freeze
      @offset = offset.freeze
    end
  end

  attr_reader :solved, :already_tried

  def initialize(lines)
    @already_tried = Hash.new { [] }
    @solved = solve(parse(lines))
  end

  def parse(lines)
    lines
      .chunk(&:empty?)
      .reject(&:first)
      .map(&:last)
      .map(&method(:parse_scanner))
  end

  def parse_scanner(chunk)
    name = chunk.first.gsub('-', '').strip
    beacons = chunk.drop(1).map { |line| Vector.elements(line.split(',').map(&:to_i)) }

    Scanner.new(name, beacons)
  end

  def solve(scanners)
    solved = [scanners.first]
    unsolved = scanners.drop(1).to_a
    while unsolved.any?
      matches = find_matches(solved, unsolved)

      raise NotImplementedError, "couldn't find any matches" if matches.empty?

      matches.each do |diff, _, unsolved_orientation, unsolved_scanner|
        solved.push(unsolved_orientation.with_offset(diff))
        unsolved.delete_if { |it| it.name == unsolved_scanner.name }
      end
    end
    solved
  end

  def find_matches(solved, unsolved)
    unsolved
      .map { |uscan| find_one(solved, uscan) }
      .select { |_d, o, _uo, _us| o >= 12 }
  end

  def find_one(solved, unsolved_scanner)
    sdiff = solved - already_tried[unsolved_scanner]
    already_tried[unsolved_scanner] += solved
    outer = Parallel.map(unsolved_scanner.possible_orientations) do |unsolved_orientation|
      overlaps = sdiff.map do |solved_scanner|
        solved_scanner.biggest_overlaps(unsolved_orientation)
      end
      overlaps.max_by { |_d, o| o } + [unsolved_orientation, unsolved_scanner]
    end
    outer.max_by { |_d, o, _uo, _us| o }
  end
end

day19 = Day19.new(ARGF.map(&:chomp).freeze)
p part1: day19.part1
p part2: day19.part2
