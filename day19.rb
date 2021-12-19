#!/usr/bin/env ruby
# frozen_string_literal: true

class Day19
  def part1
    solved = scanners.first
    unsolved = scanners.drop(1)
  end

  def part2
  end

  private

  class Scanner
    attr_reader :name, :beacons

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
        beacons << line.split(',').map(&:to_i).map(&:freeze)
      end
    end
    @scanners = scanners.freeze
  end
end

day19 = Day19.new(ARGF.map(&:chomp).freeze)
p part1: day19.part1
p part2: day19.part2
