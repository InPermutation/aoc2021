#!/usr/bin/env ruby
# frozen_string_literal: true

class Day20
  def part1
    img = @input_image
    2.times do |n|
      img = enhance(img)
      self.class.debug_image(img)
    end
    img.length
  end

  def part2; end

  private

  def enhance(img)
    res = {}
    self.class.bounds(img).each do |coord|
      nv = self.class.window_centered(coord, img)
      enhanced = enhancement_algorithm[nv]
      res[coord] = enhanced if enhanced
    end
    res
  end

  def light?(ch)
    ch == '#'
  end

  def dark?(ch)
    ch == '.'
  end

  WINDOW_OFFSETS = [-1, 0, 1].product([-1, 0, 1]).map(&:freeze).freeze
  def self.window_centered(coord, img)
    cx, cy = coord
    WINDOW_OFFSETS.map { |dy, dx| img[[cx + dx, cy + dy]] ? '1' : '0' }.to_a.join.to_i(2)
  end

  def self.bounds(img)
    bounds_x(img).to_a.product(bounds_y(img).to_a)
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
    raise StandardError, 'oh_no' if @enhancement_algorithm.first && @enhancement_algorithm.last
    raise StandardError, "512 != #{@enhancement_algorithm.length}" unless @enhancement_algorithm.length == 512

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
puts "(5294 is too low)"
p part2: day20.part2
