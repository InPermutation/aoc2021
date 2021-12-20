#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

class Day19
  def part1
    solved = scanners.take(1)
    unsolved = scanners.drop(1)
    while unsolved.any?
      find_match!(solved, unsolved)
    end
  end

  def find_match!(solved, unsolved)
    p :find_match!, solved.length, unsolved.length
    unsolved.each do |unsolved_scanner|
      unsolved_scanner.possible_orientations.each.with_index do |unsolved_orientation, i|
        p un: i
        solved.each do |solved_scanner|
          overlap = solved_scanner.biggest_overlaps(unsolved_orientation)
          if overlap.length > 12
            solved.add(unsolved_orientation)
            unsolved.remove(unsolved_scanner)
            return
          end
        end
      end
    end
    raise NotImplementedError, "couldn't find any matches"
  end

  def part2
  end

  private

  class Scanner
    attr_reader :name, :beacons

    ORDERINGS = [0, 1, 2].permutation(3).to_a.uniq.freeze
    REFLECTIONS = [-1, 1].product([-1, 1]).product([-1, 1]).map(&:flatten).to_a.freeze
    ALL_ROTATIONS = ORDERINGS.product(REFLECTIONS).freeze
    def possible_orientations
      ALL_ROTATIONS.map { |ordering, reflection|
        n = beacons.map { |b|
          bo = Vector.elements(b.to_a.values_at(*ordering))
          Vector.elements(bo.zip(reflection).map { |c, x| c * x })
        }
        Scanner.new(name, n)
      }
    end

    def biggest_overlaps(other)
      possible_offsets = beacons.product(other.beacons).map { |s, u| u - s }.uniq

      overlaps = possible_offsets.map do |diff|
        #p diff: diff, first_beacon: beacons[0], first_other: other.beacons[0], d: other.beacons[0] - diff
        opoints = other.beacons.map { |beac| beac - diff }
        opoints & beacons
      end
      p count_overlaps: overlaps.map(&:length).uniq
      overlaps.max_by(&:length)
    end

    private

    def initialize(name, beacons)
      @name = name
      @beacons = beacons
    end
  end

  attr_reader :scanners

  def initialize(lines)
    @scanners = []
    name = nil
    beacons = nil

    lines.each do |line|
      next if line.empty?
      if line.start_with?('---')
        @scanners << Scanner.new(name, beacons.freeze) if name
        name = line.gsub('---', '').strip.freeze
        beacons = []
      else
        beacons << Vector.elements(line.split(',').map(&:to_i))
      end
    end
    @scanners = scanners.freeze
  end
end

day19 = Day19.new(ARGF.map(&:chomp).freeze)
p part1: day19.part1
p part2: day19.part2
