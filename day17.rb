#!/usr/bin/env ruby
# frozen_string_literal: true

require 'io/console'

class Day17
  def part1
    hits.map(&:max_y).max
  end

  def part2
  end

  private

  attr_reader :target
  Target = Struct.new(:x, :y)

  def hits
    res = []
    (target.y.min..1000).each do |vyi| # TODO: is 1000 correct?
      puts vyi
      (0..target.x.max).each do |vxi|
        probe = Probe.new(vxi, vyi)
        res << probe if ever_hits?(probe)
      end
    end
    res
  end

  def ever_hits?(probe)
    loop do
      return true if hit(probe)
      return false if missed(probe)
      probe.step!
    end
  end

  def hit(probe)
    return target.x.include?(probe.x) && target.y.include?(probe.y)
  end

  def missed(probe)
    return true if probe.y < target.y.min && probe.vx.negative?
    return true if probe.x > target.x.max
    return false unless probe.vx == 0
    return true if probe.x < target.x.min
    return false unless probe.vy.negative?

    probe.y < target.y.min
  end

  class Probe
    attr_reader :x, :y, :vx, :vy, :max_y

    def step!
      @x += vx
      @y += vy
      @max_y = @y if @y > @max_y
      if vx > 0
        @vx -= 1
      elsif vx < 0
        @vx += 1
      end
      @vy -= 1
      self
    end

    def inspect
      "Probe<pos=(#{x}, #{y}) vel=(#{vx}, #{vy}) max_y=#{max_y}>"
    end

    alias_method :to_s, :inspect

    private

    def initialize(vx, vy)
      @x = @y = @max_y = 0
      @vx = vx
      @vy = vy
    end
  end

  def initialize(lines)
    raise StandardError, 'wrong # of lines' if lines.count != 1
    xrange, yrange = lines[0]
      .delete_prefix('target area: ')
      .split(', ')
      .map { |boundstr| boundstr.split('=')[1].split('..').map(&:to_i) }
      .map { |min, max| Range.new(min, max) }
    @target = Target.new(xrange, yrange)
  end
end

day17 = Day17.new(ARGF.map(&:chomp).freeze)
p part1: day17.part1
p part2: day17.part2
