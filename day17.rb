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
    @hits ||= (target.y.min..1000).flat_map do |vyi| # TODO: is 1000 correct?
      (0..target.x.max)
        .map { |vxi| Probe.new(vxi, vyi, target) }
        .select(&:ever_hits?)
    end
  end

  class Probe
    attr_reader :x, :y, :vx, :vy, :max_y, :target

    def inspect
      "Probe<pos=(#{x}, #{y}) vel=(#{vx}, #{vy}) max_y=#{max_y}>"
    end

    def ever_hits?
      loop do
        return true if hit
        return false if missed

        step!
      end
    end

    alias to_s inspect

    private

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

    def hit
      target.x.include?(x) && target.y.include?(y)
    end

    def missed
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
