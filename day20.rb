#!/usr/bin/env ruby
# frozen_string_literal: true

class Day20
  def part1
    2.times
     .reduce(@input_image) { |img, _| enhance(img) }
     .values.tally['#']
  end

  def part2
    50.times
      .reduce(@input_image) { |img, ix| p ix ; enhance(img) }
      .values.tally['#']
  end

  private

  def enhance(img)
    res = Hash.new(img.default)
    self.class.bounds(img).each do |coord|
      nv = self.class.window_centered(coord, img)
      res[coord] = enhancement_algorithm[nv]
    end
    res.default = case res.default
                  when '.'
                    enhancement_algorithm[0]
                  when '#'
                    enhancement_algorithm[511]
                  else
                    raise NotImplementedError, res.default
                  end
    res.freeze
  end

  WINDOW_OFFSETS = [-1, 0, 1].product([-1, 0, 1]).map(&:freeze).freeze
  BINARY_FROM_LIGHT = '.#'.chars.freeze.method(:find_index)
  def self.window_centered(coord, img)
    cx, cy = coord
    WINDOW_OFFSETS
      .map { |dy, dx| img[[cx + dx, cy + dy]] }
      .map(&BINARY_FROM_LIGHT)
      .to_a
      .join
      .to_i(2)
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
    return
    bounds_y(img).each do |y|
      bounds_x(img).each do |x|
        printf (img[[x, y]]).to_s
      end
      puts
    end
  end

  attr_reader :enhancement_algorithm, :input_image

  def initialize(lines)
    @enhancement_algorithm = lines[0].freeze
    raise StandardError, 'the vastness of space brightens your face' if
    @enhancement_algorithm[0] == '#' && @enhancement_algorithm[-1] == '#'
    raise StandardError, "512 != #{@enhancement_algorithm.length}" unless @enhancement_algorithm.length == 512

    @input_image = Hash.new('.')
    lines.drop(2).each.with_index do |line, y|
      line.chars.each.with_index do |ch, x|
        input_image[[x, y]] = ch
      end
    end
    @input_image = input_image.freeze
    self.class.debug_image(input_image)
  end
end

day20 = Day20.new(ARGF.map(&:chomp).freeze)
p part1: day20.part1
p part2: day20.part2
