#!/usr/bin/env ruby
# frozen_string_literal: true

require 'io/console'

class Day17
  def part1
    hits.map(&:max_y).max
  end

  def part2
    hits.length
  end

  private

  attr_reader :target

  Target = Struct.new(:x, :y)

  def hits
    @hits ||= (target.y.min..1000).flat_map do |vyi| # TODO: is 1000 correct?
      (0..target.x.max)
        .map { |vxi| Probe.new(vxi, vyi) }
        .select { |probe| ever_hits?(probe) }
    end
  end

  def ever_hits?(probe)
    loop do
      return true if hit(probe)
      return false if missed(probe)

      probe.step!
    end
  end

  def hit(probe)
    target.x.include?(probe.x) && target.y.include?(probe.y)
  end

  def missed(probe)
    return true if probe.y < target.y.min && probe.vx.negative?
    return true if probe.x > target.x.max
    return false unless probe.vx.zero?
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
      if vx.positive?
        @vx -= 1
      elsif vx.negative?
        @vx += 1
      end
      @vy -= 1
      self
    end

    def inspect
      "Probe<pos=(#{x}, #{y}) vel=(#{vx}, #{vy}) max_y=#{max_y}>"
    end

    alias to_s inspect

    private

    def initialize(vxi, vyi)
      @x = @y = @max_y = 0
      @vx = vxi
      @vy = vyi
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
