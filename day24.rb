#!/usr/bin/env ruby
# frozen_string_literal: true

class Day24
  def self.coeff(slice)
    # slice: 18 lines beginning with 'inp w'
    # Z is the accumulator
    # W, X, and Y are temporary
    case slice
      in
      ['inp w', # W is always the current input
       'mul x 0', # X is always reset to 0
       'add x z', 'mod x 26',
       divz_a, addx_b,
       'eql x w', 'eql x 0',
       'mul y 0', # Y is always reset to 0
       'add y 25', 'mul y x', 'add y 1',
       'mul z y', 'mul y 0', 'add y w',
       addy_c, 'mul y x', 'add z y']

      # (Z's denominator) is always 1 or 26
      raise "unexpected a '#{divz_a}'" unless ['div z 1', 'div z 26'].include? divz_a
      [
        divz_a.delete_prefix('div z ').to_i,
        addx_b.delete_prefix('add x ').to_i,
        addy_c.delete_prefix('add y ').to_i
      ]
    else
      raise StandardError, slice
    end
  end

  def self.step(a, b, c, w, z)
    x = 0
    x += z
    x %= 26
    z /= a
    x += b
    x = (x == w) ? 1 : 0
    x = (x == 0) ? 1 : 0
    y = 0
    y += 25
    y *= x
    y += 1
    z *= y
    y *= 0
    y += w
    y += c
    y *= x
    z += y
    z
  end

  def part1
    coefficients = lines.each_slice(18).map(&self.class.method(:coeff))
    best = { 0 => 0 }
    coefficients
      .each do |a, b, c|
        newbest = {}
        p items: best.length, a: a, b: b, c: c
        best.each do |z, inp|
          (1..9).each do |w|
            newz = Day24.step(a, b, c, w, z)
            #p z: z, a: a, b: b, c: c, w: w, newz: newz
            newbest[newz] = inp * 10 + w
          end
        end
        best = newbest
        p best.min_by { |z, _| z }
      end
    best[0]
  end

  def part2
  end

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end
end

day24 = Day24.new(ARGF.map(&:chomp).freeze)
p part1: day24.part1
p part2: day24.part2
