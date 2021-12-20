#!/usr/bin/env ruby
# frozen_string_literal: true

class Day20
  def part1; end
  def part2; end

  private

  def light?(ch)
    ch == '#'
  end

  def dark?(ch)
    ch == '.'
  end

  def self.bounds_y(img)
    miny, maxy = img.keys.map(&:last).minmax
    # go 1 beyond the actual bounds
    # so the enhancement algorithm can expand if necessary
    (miny - 1)..(maxy + 1)
  end

  def self.bounds_x(img)
    minx, maxx = img.keys.map(&:first).minmax
    # go 1 beyond the actual bounds
    # so the enhancement algorithm can expand if necessary
    (minx - 1)..(maxx + 1)
  end

  def self.debug_image(img)
    bounds_y(img).each do |y|
      bounds_x(img).each do |x|
        printf img[[x, y]] ? '#' : '.'
      end
      puts
    end
  end

  attr_reader :enhancement_algorithm, :input_image

  def initialize(lines)
    @enhancement_algorithm = lines[0].chars.map(&method(:light?)).freeze
    raise StandardError, 'All-dark enhancement must remain dark' if @enhancement_algorithm.first

    @input_image = {}
    lines.drop(2).each.with_index do |line, y|
      line.chars.each.with_index do |ch, x|
        if light?(ch)
          input_image[ [x, y] ] = true
        end
      end
    end
    @input_image = input_image.freeze
    self.class.debug_image(input_image)
  end
end

day20 = Day20.new(ARGF.map(&:chomp).freeze)
p part1: day20.part1
p part2: day20.part2
