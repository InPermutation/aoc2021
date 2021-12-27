#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'
require 'set'
require 'parallel'

class Day19
  def part1
    solved.flat_map(&:beacons).uniq.length
  end

  def find_matches!(solved, unsolved)
    utmost = unsolved.map do |unsolved_scanner|
      sdiff = solved - already_tried[unsolved_scanner]
      already_tried[unsolved_scanner] += solved
      outer = Parallel.map(unsolved_scanner.possible_orientations) do |unsolved_orientation|
        overlaps = sdiff.map do |solved_scanner|
          solved_scanner.biggest_overlaps(unsolved_orientation)
        end
        overlaps.max_by { |o, _d| o } + [unsolved_orientation, unsolved_scanner]
      end
      outer.max_by { |o, _d, _uo, _us| o }
    end

    matches = utmost.select { |o, _d, _uo, _us| o >= 12 }
    raise NotImplementedError, "couldn't find any matches" if matches.empty?

    matches.each do |olength, diff, unsolved_orientation, unsolved_scanner|
      solved.push(unsolved_orientation.with_offset(diff))
      unsolved.delete_if { |it| it.name == unsolved_scanner.name }
      puts "found TODO - #{unsolved_scanner.name}. diff = #{diff}. #{unsolved.length} remain."
    end
  end

  def part2
    offsets = solved
      .map(&:offset_from_0)
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
    attr_reader :name, :beacons, :offset_from_0

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
      ALL_ROTATIONS.map { |ordering, reflection|
        n = beacons.map { |b|
          bo = Vector.elements(b.to_a.values_at(*ordering))
          Vector.elements(bo.zip(reflection).map { |c, x| c * x })
        }
        Scanner.new(name, n)
      }
    end

    def with_offset(d)
      n = beacons.map { |b| b + d }
      Scanner.new(name, n, d)
    end

    def biggest_overlaps(other)
      possible_offsets = beacons.product(other.beacons).map { |s, u| s - u }.uniq
      other_beacons = other.beacons.to_a
      beacons_set = beacons.to_set

      overlaps = possible_offsets.map do |diff|
        opoints = other_beacons.map { |beac| beac + diff }
        [(beacons_set & opoints).length, diff]
      end
      overlaps.max_by { |olength, _diff| olength }
    end

    private

    def initialize(name, beacons, offset_from_0 = Vector[0, 0, 0])
      @name = name
      @beacons = beacons.freeze
      @offset_from_0 = offset_from_0
    end
  end

  attr_reader :solved, :already_tried

  def initialize(lines)
    @already_tried = Hash.new { Array.new }

    scanners = []
    name = nil
    beacons = nil

    lines.each do |line|
      next if line.empty?
      if line.start_with?('---')
        scanners << Scanner.new(name, beacons) if name
        name = line.gsub('---', '').strip.freeze
        beacons = []
      else
        beacons << Vector.elements(line.split(',').map(&:to_i))
      end
    end
    scanners << Scanner.new(name, beacons)
    solved = scanners.take(1).to_a
    unsolved = scanners.drop(1).to_a
    while unsolved.any?
      find_matches!(solved, unsolved)
    end
    @solved = solved
  end
end

day19 = Day19.new(ARGF.map(&:chomp).freeze)
p part1: day19.part1
p part2: day19.part2
