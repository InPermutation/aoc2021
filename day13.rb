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
    raise NotImplementedError, :part2
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
    case fold
    in ['x', x]
      fold_x(dots, x)
    in ['y', y]
      fold_y(dots, y)
    end
  end

  def fold_x(dots, coord)
    dots.map do |x, y|
      case x
      when ..coord
        [coord + coord - x, y]
      else
        [x, y]
      end
    end
  end

  def fold_y(dots, coord)
    dots.map do |x, y|
      case y
      when ..coord
        [x, coord + coord - y]
      else
        [x, y]
      end
    end
  end
end
day13 = Day13.new(ARGF.map(&:chomp).freeze)
p part1: day13.part1
p part2: day13.part2
