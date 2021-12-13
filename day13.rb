#!/usr/bin/env ruby
# frozen_string_literal: true

class Day13
  def part1
    folds
      .take(1)
      .reduce(initial_dots, &method(:fold))
      .uniq
      .length
  end

  def part2
    show folds
      .reduce(initial_dots, &method(:fold))
      .uniq
  end

  private

  attr_reader :initial_dots, :folds

  def initialize(lines)
    @initial_dots = lines
                    .take_while { |line| line.include? ',' }
                    .map { |line| line.split(',').map(&:to_i).freeze }
                    .freeze

    @folds = lines
             .drop_while { |line| line.include? ',' }
             .drop(1)
             .map { |line| line.gsub(/^fold along /, '') }
             .map { |fold| fold.split '=' }
             .map do |fold|
               fold[1] = fold[1].to_i
               fold.freeze
             end
             .freeze
  end

  def fold(dots, fold)
    axis, coord = fold
    dots.map do |x, y|
      if axis == 'x' and x > coord
        [coord + coord - x, y]
      elsif axis == 'y' and y > coord
        [x, coord + coord - y]
      else
        [x, y]
      end
    end
  end

  def show(dots)
    max_x = dots.map { |x, _y| x }.max
    max_y = dots.map { |_x, y| y }.max
    (max_y + 1).times.map do |y|
      (max_x + 1).times.map do |x|
        dots.include?([x, y]) ? '#' : '.'
      end.join('')
    end.join("\n")
  end
end
day13 = Day13.new(ARGF.map(&:chomp).freeze)
p part1: day13.part1
puts "part2:\n#{day13.part2}"
