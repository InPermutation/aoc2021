#!/usr/bin/env ruby
# frozen_string_literal: true

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
    raise NotImplementedError, 'ymin+' unless target.y.min.negative?
    raise NotImplementedError, 'ymax+' unless target.y.max.negative?
    # For targets completely below the screen,
    # the probe will always pass y=0 a second time.
    # When it does, it will have vy = -vyi.
    # All probes with vyi > the distance to the bottom of the target
    # are guaranteed not to intersect the target, because the first
    # negative y will be below the bottom of the target.
    max_vyi = -target.y.min + 1
    min_vyi = target.y.min
    @hits ||= (min_vyi..max_vyi)
      .flat_map do |vyi|
        probes = (0..target.x.max)
          .map { |vxi| Probe.new(vxi, vyi, target).play_out! }
          .select(&:hit?)
      end
  end

  class Probe
    attr_reader :x, :y, :vx, :vy, :max_y, :target

    def inspect
      "Probe<pos=(#{x}, #{y}) vel=(#{vx}, #{vy}) max_y=#{max_y}>"
    end

    def play_out!
      step! until hit? || missed?
      self
    end

    alias to_s inspect

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
    end

    def hit?
      target.x.include?(x) && target.y.include?(y)
    end

    def missed?
      falling_below? || too_right? || stopped_short?
    end

    def falling_below?
      y < target.y.min && vy.negative?
    end

    def too_right?
      x > target.x.max && !vx.negative?
    end

    def stopped_short?
      x < target.x.min && !vx.positive?
    end

    private

    def initialize(vxi, vyi, target)
      @x = @y = @max_y = 0
      @vx = vxi
      @vy = vyi
      @target = target
    end
  end

  def initialize(lines)
    raise StandardError, 'wrong # of lines' if lines.count != 1

    xrange, yrange = lines[0]
                     .delete_prefix('target area: ')
                     .split(', ')
                     .map { |boundstr| boundstr.split('=')[1].split('..').map(&:to_i) }
                     .map { |min, max| Range.new(min, max).freeze }
    @target = Target.new(xrange, yrange)
  end
end

day17 = Day17.new(ARGF.map(&:chomp).freeze)
p part1: day17.part1
p part2: day17.part2
