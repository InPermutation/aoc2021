#!/usr/bin/env ruby
# frozen_string_literal: true

class Day16
  Node = Struct.new(:ver, :type, :children)

  def part1
    tree = Day16.valid_tree!(Day16.parse(binary))
    Day16.sum_versions(tree)
  end

  def part2
  end

  private

  attr_reader :binary

  def initialize(lines)
    raise StandardError, 'too many lines' if lines.count > 1
    @binary = lines[0].chars.map { |hex| hex.to_i(16) }.map { |num| num.to_s(2).rjust(4, '0') }.join
  end

  def self.parse(so_far)
    /^(?<ver>[01]{3})(?<type>[01]{3})(?<so_far>.*)$/ =~ so_far
    ver = ver.to_i(2)
    type = type.to_i(2)

    case type
    when 4
      # literal
      n = 0
      keep_reading = '1'
      until keep_reading == '0' do
        /^(?<keep_reading>[01])(?<bits>[01]{4})(?<so_far>.*)$/ =~ so_far
        n = n << 0x4 | bits.to_i(2)
      end
      return [[ver, type, n], so_far]
    else
      # operator
      length_type_id = so_far[0]
      so_far = so_far[1..]
      case length_type_id
      when '1'
        length = so_far[0, 11].to_i(2)
        so_far = so_far[11..]
        children = length.times.map do
          parsed, so_far = parse(so_far)
          parsed
        end
        return [[ver, type, *children], so_far]
      when '0'
        length = so_far[0, 15].to_i(2)
        substr = so_far[15, length]
        so_far = so_far[(15+length)..]
        children = []
        until substr =~ /^0*$/ do
          tree, substr = parse(substr)
          children << tree
        end
        return [[ver, type, *children], so_far]
      end
    end
  end

  def self.sum_versions(tree)
    ver = tree[0]
    type = tree[1]
    children = tree[2..]
    type == 4 ? ver : ver + children.map(&method(:sum_versions)).sum
  end

  def self.valid_tree!(arr)
    tree, trailer = arr
    raise StandardError, trailer unless /^0*$/ =~ trailer
    tree
  end
end

def test(name, input, expected_output)
  actual_output = Day16.new([input].freeze).part1

  if actual_output != expected_output
    raise StandardError, "#{name}: #{actual_output || 'nil'} != #{expected_output} (in: #{input})"
  end
end

test 's', 'D2FE28', 6
test 'ex1', '8A004A801A8002F478', 16
test 'ex2', '620080001611562C8802118E34', 12
test 'ex3', 'C0015000016115A2E0802F182340', 23
test 'ex4', 'A0016C880162017C3686B18A3D4780', 31

day16 = Day16.new(ARGF.map(&:chomp).freeze)
p part1: day16.part1
p part2: day16.part2
