#!/usr/bin/env ruby
# frozen_string_literal: true

class Day16
  Node = Struct.new(:ver, :type, :children)

  def part1
    tree = Day16.valid_tree!(Day16.parse(binary))
    Day16.sum_versions(tree)
  end

  def part2
    tree = Day16.valid_tree!(Day16.parse(binary))
    Day16.evaluate(tree)
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
    ver, type = tree[0], tree[1]
    children = tree[2..]
    type == 4 ? ver : ver + children.map(&method(:sum_versions)).sum
  end

  def self.valid_tree!(arr)
    tree, trailer = arr
    raise StandardError, trailer unless /^0*$/ =~ trailer
    tree
  end

  def self.evaluate(tree)
    ver, type = tree[0], tree[1]
    children = tree[2..]
    case type
    when 0
      children.map(&method(:evaluate)).sum
    when 1
      children.map(&method(:evaluate)).reduce(&:*)
    when 2
      children.map(&method(:evaluate)).min
    when 3
      children.map(&method(:evaluate)).max
    when 4
      children[0]
    when 5
      evaluate(children[0]) > evaluate(children[1]) ? 1 : 0
    when 6
      evaluate(children[0]) < evaluate(children[1]) ? 1 : 0
    when 7
      evaluate(children[0]) == evaluate(children[1]) ? 1 : 0
    else
      raise NotImplementedError, "type #{type}"
    end
  end
end

def test(msg, input, expected_output)
  actual_output = Day16.new([input].freeze).send(msg)

  if actual_output != expected_output
    raise StandardError, "#{msg}: #{actual_output || 'nil'} != #{expected_output} (in: #{input})"
  end
end

test :part1, 'D2FE28', 6
test :part1, '8A004A801A8002F478', 16
test :part1, '620080001611562C8802118E34', 12
test :part1, 'C0015000016115A2E0802F182340', 23
test :part1, 'A0016C880162017C3686B18A3D4780', 31

test :part2, 'C200B40A82', 3
test :part2, '04005AC33890', 54
test :part2, '880086C3E88112', 7
test :part2, 'CE00C43D881120', 9
test :part2, 'D8005AC2A8F0', 1
test :part2, 'F600BC2D8F', 0
test :part2, '9C005AC2F8F0', 0
test :part2, '9C0141080250320F1802104A08', 1

day16 = Day16.new(ARGF.map(&:chomp).freeze)
p part1: day16.part1
p part2: day16.part2
