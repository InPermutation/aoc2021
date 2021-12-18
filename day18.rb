#!/usr/bin/env ruby
# frozen_string_literal: true


class Day18
  class TreeNode
    attr_accessor :left, :right
    attr_reader :depth

    def eql?(other)
      return false if other.class != TreeNode
      return other.leaf? && left == other.left if leaf?

      left.eql?(other.left) && right.eql?(other.right)
    end

    def inspect
      return "#{left.inspect}" if leaf?

      "[#{left.inspect},#{right.inspect}]"
    end

    def leaf?
      right.nil?
    end

    def self.from_array(value)
      case value
      in [l, r]
        from_array(l) + from_array(r)
      else
        TreeNode.new(value, nil, 0)
      end
    end

    def +(right)
      raise StandardError, "has parent: #{inspect}" unless depth == 0
      raise StandardError, "has parent: #{right.inspect}" unless depth == 0

      TreeNode.new(self.with_incr_parent, right.with_incr_parent, 0)
    end

    def with_incr_parent
      return TreeNode.new(left, nil, depth + 1) if leaf?
      TreeNode.new(left.with_incr_parent, right.with_incr_parent, depth + 1)
    end

    def split!
      return false unless leaf?
      return false unless left >= 10

      q, r = left.divmod(2)
      self.left = TreeNode.new(q, nil, depth + 1)
      self.right = TreeNode.new(q + r, nil, depth + 1)
      true
    end

    def reduce!
      loop do
        next if explode_once!
        next if split_once!
        return
      end
    end

    def split_once!
      leaf_nodes.each do |node|
        return true if node.split!
      end
      false
    end

    def explode_once!
      explodable_nodes.take(1).each do |explod|
        raise StandardError, explod.inspect unless explod.left.leaf? && explod.right.leaf?
        lval, rval = explod.left.left, explod.right.left

        lnodes = leaf_nodes
        lix = lnodes.find_index(explod.left)
        raise StandardError, explod.inspect if lix.nil?
        lnodes[lix - 1].left += lval if lix - 1 >= 0
        lnodes[lix + 2].left += rval if lix + 2 < lnodes.length
        explod.left = 0
        explod.right = nil

        return true
      end
      return false
    end

    def explodable_nodes
      all_nodes.select(&:explodable?)
    end

    def explodable?
      !leaf? && depth == 4
    end

    def all_nodes
      return [self] if leaf?
      [self] + left.all_nodes + right.all_nodes
    end

    def leaf_nodes
      return [self] if leaf?

      left.leaf_nodes + right.leaf_nodes
    end

    def magnitude
      return left if leaf?

      3 * left.magnitude + 2 * right.magnitude
    end

    private

    def initialize(left, right, depth)
      if right.nil?
        raise StandardError, "not integer: #{left.inspect} (#{left.class})" unless left.class == Integer
      end
      raise TypeError, "depth: #{depth} #{depth.class}" unless depth.class == Integer
      @left = left
      @right = right
      @depth = depth
    end
  end

  def part1
    arr = lines.map { |line| eval(line) } # DIRRRTY eval
    Day18.final_sum(arr).magnitude
  end

  def part2
    arr = lines.map { |line| eval(line) } # DIRRRTY eval
    Day18.maximum_pair_sum(arr)
  end

  def self.final_sum(arr)
    arr
      .map(&TreeNode.method(:from_array))
      .reduce { |prev, node|
        tn = prev + node
        tn.reduce!
        tn
      }
  end

  def self.maximum_pair_sum(arr)
    arr
      .permutation(2)
      .map { |l, r|
        l = TreeNode.from_array(l)
        r = TreeNode.from_array(r)
        s = l + r
        s.reduce!
        s.magnitude
      }
      .max
  end

  private

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end
end
TreeNode = Day18::TreeNode

class AssertionError < StandardError; end

def assert(msg = 'Assertion failed')
  raise AssertionError, msg unless yield

  printf '.'
end

def assert_equal(expected, actual)
  expected = TreeNode.from_array(expected)
  actual = TreeNode.from_array(actual) if actual.class == Integer || actual.class == Array
  assert("\nExpect #{expected.inspect}\nActual #{actual.inspect}") { expected.eql? actual }
end

assert_equal [1, 2], TreeNode.from_array([1, 2])
assert("Identity equals") { TreeNode.from_array([1, 2]) !=
                            TreeNode.from_array([1, 2]) }
assert_equal [[1, 2], [[3, 4], 5]], TreeNode.from_array([1, 2]) + TreeNode.from_array([[3, 4], 5])
assert_equal [[[[1, 1], [2, 2]], [3, 3]], [4, 4]], [
    [1, 1],
    [2, 2],
    [3, 3],
    [4, 4]
].map(&TreeNode.method(:from_array)).reduce(&:+)
assert_equal 9, TreeNode.from_array(9).tap(&:split!)
assert_equal [5, 5], TreeNode.from_array(10).tap(&:split!)
assert_equal [5, 6], TreeNode.from_array(11).tap(&:split!)
assert_equal [6, 6], TreeNode.from_array(12).tap(&:split!)

assert_equal [9, 3], TreeNode.from_array([9, 3]).tap(&:split_once!) # nothing over 10 -> don't split anything
assert_equal [[5, 5], 3], TreeNode.from_array([10, 3]).tap(&:split_once!)
assert_equal [[5, 5], 11], TreeNode.from_array([10, 11]).tap(&:split_once!) # only split leftmost value
assert_equal [[9, [5, 5]], 11], TreeNode.from_array([[9, 10], 11]).tap(&:split_once!) # only split leftmost value

assert_equal 29, TreeNode.from_array([9, 1]).magnitude
assert_equal 21, TreeNode.from_array([1, 9]).magnitude
assert_equal 129, TreeNode.from_array([[9, 1], [1, 9]]).magnitude
assert_equal 143, TreeNode.from_array([[1, 2], [[3, 4], 5]]).magnitude
assert_equal 1384, TreeNode.from_array([[[[0, 7], 4], [[7, 8], [6, 0]]], [8, 1]]).magnitude
assert_equal 445, TreeNode.from_array([[[[1, 1], [2, 2]], [3, 3]], [4, 4]]).magnitude
assert_equal 791, TreeNode.from_array([[[[3, 0], [5, 3]], [4, 4]], [5, 5]]).magnitude
assert_equal 1137, TreeNode.from_array([[[[5, 0], [7, 4]], [5, 5]], [6, 6]]).magnitude
assert_equal 3488, TreeNode.from_array([[[[8, 7], [7, 7]], [[8, 6], [7, 7]]], [[[0, 7], [6, 6]], [8, 7]]]).magnitude

assert_equal [5, [7, 2]], TreeNode.from_array([5, [7, 2]]).tap(&:explode_once!) # no explosion
assert_equal [[[[0, 9], 2], 3], 4], TreeNode.from_array([[[[[9, 8], 1], 2], 3], 4]).tap(&:explode_once!)
assert_equal [7, [6, [5, [7, 0]]]], TreeNode.from_array([7, [6, [5, [4, [3, 2]]]]]).tap(&:explode_once!)
assert_equal [[6, [5, [7, 0]]], 3], TreeNode.from_array([[6, [5, [4, [3, 2]]]], 1]).tap(&:explode_once!)
assert_equal [[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]],
             TreeNode.from_array([[3, [2, [1, [7, 3]]]], [6, [5, [4, [3, 2]]]]]).tap(&:explode_once!)
assert_equal [[3, [2, [8, 0]]], [9, [5, [7, 0]]]],
  TreeNode.from_array([[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]]).tap(&:explode_once!)

assert_equal [[[[1, 1], [2, 2]], [3, 3]], [4, 4]], Day18.final_sum(
  [
    [1, 1],
    [2, 2],
    [3, 3],
    [4, 4]
  ]
)

assert_equal [[[[3,0],[5,3]],[4,4]],[5,5]], Day18.final_sum(
  [
    [1,1],
    [2,2],
    [3,3],
    [4,4],
    [5,5]
  ]
)

assert_equal [[[[5,0],[7,4]],[5,5]],[6,6]], Day18.final_sum(
  [
    [1,1],
    [2,2],
    [3,3],
    [4,4],
    [5,5],
    [6,6]
  ]
)


assert_equal [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]], Day18.final_sum(
  [
    [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]],
    [7,[[[3,7],[4,3]],[[6,3],[8,8]]]],
    [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]],
    [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]],
    [7,[5,[[3,8],[1,4]]]],
    [[2,[2,2]],[8,[8,1]]],
    [2,9],
    [1,[[[9,3],9],[[9,0],[0,7]]]],
    [[[5,[7,4]],7],1],
    [[[[4,2],2],6],[8,7]]
  ]
)

example_assignment = [
  [[[0, [5, 8]], [[1, 7], [9, 6]]], [[4, [1, 2]], [[1, 4], 2]]],
  [[[5, [2, 8]], 4], [5, [[9, 9], 0]]],
  [6, [[[6, 2], [5, 6]], [[7, 6], [4, 7]]]],
  [[[6, [0, 7]], [0, 9]], [4, [9, [9, 0]]]],
  [[[7, [6, 4]], [3, [1, 3]]], [[[5, 5], 1], 9]],
  [[6, [[7, 3], [3, 2]]], [[[3, 8], [5, 7]], 4]],
  [[[[5, 4], [7, 7]], 8], [[8, 3], 8]],
  [[9, 3], [[9, 9], [6, [4, 9]]]],
  [[2, [[7, 7], 7]], [[5, 8], [[9, 3], [0, 2]]]],
  [[[[5, 2], 5], [8, [3, 7]]], [[5, [7, 5]], [4, 4]]]
]
fsum = [[[[6, 6], [7, 6]], [[7, 7], [7, 0]]], [[[7, 7], [7, 7]], [[7, 8], [9, 9]]]]
assert_equal fsum, Day18.final_sum(example_assignment)
assert_equal 4140, TreeNode.from_array(fsum).magnitude

assert_equal [[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]], Day18.final_sum([
    [[2, [[7, 7], 7]], [[5, 8], [[9, 3], [0, 2]]]],
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
])
assert_equal 3993, TreeNode.from_array([[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]]).magnitude
assert_equal 3993, Day18.maximum_pair_sum(example_assignment)

puts "\nTests passed"

day18 = Day18.new(ARGF.map(&:chomp).freeze)
p part1: day18.part1
p part2: day18.part2
