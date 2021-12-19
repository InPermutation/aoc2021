#!/usr/bin/env ruby
# frozen_string_literal: true


class Day18
  class TreeBase
    attr_reader :depth

    def +(right)
      raise StandardError, "has parent: #{inspect}" unless depth.zero?
      raise StandardError, "has parent: #{right.inspect}" unless right.depth.zero?

      RootNode.new(self.with_incr_parent, right.with_incr_parent)
    end
  end

  class TreeNode < TreeBase
    attr_reader :left, :right

    def eql?(other)
      !other.leaf? && left.eql?(other.left) && right.eql?(other.right)
    end

    def inspect
      "[#{left.inspect},#{right.inspect}]"
    end

    def leaf?
      false
    end

    def self.from_array(value)
      case value
      in [l, r]
        # + will set depth correctly
        from_array(l) + from_array(r)
      else
        LeafNode.new(value, 0)
      end
    end

    def with_incr_parent
      TreeNode.new(left.with_incr_parent, right.with_incr_parent, depth + 1)
    end

    def explodable?
      depth == 4
    end

    def all_nodes
      left.all_nodes + [self] + right.all_nodes
    end

    def leaf_nodes
      left.leaf_nodes + right.leaf_nodes
    end

    def magnitude
      3 * left.magnitude + 2 * right.magnitude
    end

    def with_replaced(replacements)
      replacements.each do |target, replacement|
        return replacement if target == self
      end
      new_left = left.with_replaced(replacements)
      new_right = right.with_replaced(replacements)
      return self if new_left == left && new_right == right
      TreeNode.new(
        new_left,
        new_right,
        depth)
    end

    private

    def initialize(left, right, depth)
      raise StandardError, "use LeafNode" if right.nil?
      #raise StandardError, "use RootNode" if depth.zero?
      @left = left
      @right = right
      @depth = depth
    end
  end

  class RootNode < TreeNode
    def reduce
      root = self
      loop do
        prev_root = root
        next if prev_root != (root = root.explode_once!)
        next if prev_root != (root = root.split_once!)

        return root
      end
    end

    def split_once!
      leaf_nodes.each do |node|
        sp = node.split
        if sp != node
          return with_replaced([[node, sp]])
        end
      end
      self
    end

    def with_replaced(replacements)
      x = super
      RootNode.new(x.left, x.right)
    end

    def explode_once!
      explodable_nodes.take(1).each do |explod|
        lval, rval = explod.left.magnitude, explod.right.magnitude

        lnodes = leaf_nodes
        lix = lnodes.find_index(explod.left)
        raise StandardError, explod.inspect if lix.nil?
        raise StandardError, explod.inspect if lnodes.find_index(explod.right) != lix + 1

        crater = LeafNode.new(0, explod.depth)

        replacements = [
          [explod, crater]
        ]
        unless (lix - 1).negative?
          ltarget = lnodes[lix - 1]
          lreplac = LeafNode.new(ltarget.magnitude + lval, ltarget.depth)
          replacements << [ltarget, lreplac]
        end
        if lix + 2 < lnodes.length
          rtarget = lnodes[lix + 2]
          rreplac = LeafNode.new(rtarget.magnitude + rval, rtarget.depth)
          replacements << [rtarget, rreplac]
        end
        return with_replaced(replacements)
      end
      self
    end

    def explodable_nodes
      all_nodes.select(&:explodable?)
    end

    private

    def initialize(left, right)
      raise StandardError, "use LeafNode" if right.nil?
      @left = left
      @right = right
      @depth = 0
    end
  end

  class LeafNode < TreeBase
    attr_reader :magnitude

    def eql?(other)
      other.leaf? && other.magnitude == magnitude
    end

    def leaf?
      true
    end

    def explodable?
      false
    end

    def with_incr_parent
      LeafNode.new(magnitude, depth + 1)
    end

    def with_replaced(replacements)
      replacements.each do |target, replacement|
        return replacement if target == self
      end
      self
    end

    def split
      return self unless magnitude >= 10

      q, r = magnitude.divmod(2)
      lnode = LeafNode.new(q, depth + 1)
      rnode = LeafNode.new(q + r, depth + 1)
      TreeNode.new(lnode, rnode, depth)
    end

    def leaf_nodes
      [self]
    end
    alias :all_nodes :leaf_nodes

    private

    def initialize(magnitude, depth)
      @magnitude = magnitude
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
        (prev + node).reduce
      }
  end

  def self.maximum_pair_sum(arr)
    arr
      .permutation(2)
      .map { |l, r|
        l = TreeNode.from_array(l)
        r = TreeNode.from_array(r)
        s = l + r
        s.reduce.magnitude
      }
      .max
  end

  private

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end
end
RootNode = Day18::RootNode

class AssertionError < StandardError; end

def assert(msg = 'Assertion failed')
  raise AssertionError, msg unless yield

  printf '.'
end

def assert_equal(expected, actual)
  expected = RootNode.from_array(expected)
  actual = RootNode.from_array(actual) if actual.class == Integer || actual.class == Array
  assert("\nExpect #{expected.inspect}\nActual #{actual.inspect}") { expected.eql? actual }
end

assert_equal [1, 2], RootNode.from_array([1, 2])
assert("Identity equals") { RootNode.from_array([1, 2]) !=
                            RootNode.from_array([1, 2]) }
assert_equal [[1, 2], [[3, 4], 5]], RootNode.from_array([1, 2]) + RootNode.from_array([[3, 4], 5])
assert_equal [[[[1, 1], [2, 2]], [3, 3]], [4, 4]], [
    [1, 1],
    [2, 2],
    [3, 3],
    [4, 4]
].map(&RootNode.method(:from_array)).reduce(&:+)
assert_equal 9, RootNode.from_array(9).split
assert_equal [5, 5], RootNode.from_array(10).split
assert_equal [5, 6], RootNode.from_array(11).split
assert_equal [6, 6], RootNode.from_array(12).split

assert_equal [9, 3], RootNode.from_array([9, 3]).split_once! # nothing over 10 -> don't split anything
assert_equal [[5, 5], 3], RootNode.from_array([10, 3]).split_once!
assert_equal [[5, 5], 11], RootNode.from_array([10, 11]).split_once! # only split leftmost value
assert_equal [[9, [5, 5]], 11], RootNode.from_array([[9, 10], 11]).split_once! # only split leftmost value

assert_equal 29, RootNode.from_array([9, 1]).magnitude
assert_equal 21, RootNode.from_array([1, 9]).magnitude
assert_equal 129, RootNode.from_array([[9, 1], [1, 9]]).magnitude
assert_equal 143, RootNode.from_array([[1, 2], [[3, 4], 5]]).magnitude
assert_equal 1384, RootNode.from_array([[[[0, 7], 4], [[7, 8], [6, 0]]], [8, 1]]).magnitude
assert_equal 445, RootNode.from_array([[[[1, 1], [2, 2]], [3, 3]], [4, 4]]).magnitude
assert_equal 791, RootNode.from_array([[[[3, 0], [5, 3]], [4, 4]], [5, 5]]).magnitude
assert_equal 1137, RootNode.from_array([[[[5, 0], [7, 4]], [5, 5]], [6, 6]]).magnitude
assert_equal 3488, RootNode.from_array([[[[8, 7], [7, 7]], [[8, 6], [7, 7]]], [[[0, 7], [6, 6]], [8, 7]]]).magnitude

assert_equal [5, [7, 2]], RootNode.from_array([5, [7, 2]]).explode_once! # no explosion
assert_equal [[[[0, 9], 2], 3], 4], RootNode.from_array([[[[[9, 8], 1], 2], 3], 4]).explode_once!
assert_equal [7, [6, [5, [7, 0]]]], RootNode.from_array([7, [6, [5, [4, [3, 2]]]]]).explode_once!
assert_equal [[6, [5, [7, 0]]], 3], RootNode.from_array([[6, [5, [4, [3, 2]]]], 1]).explode_once!
assert_equal [[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]],
             RootNode.from_array([[3, [2, [1, [7, 3]]]], [6, [5, [4, [3, 2]]]]]).explode_once!
assert_equal [[3, [2, [8, 0]]], [9, [5, [7, 0]]]],
  RootNode.from_array([[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]]).explode_once!

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
assert_equal 4140, RootNode.from_array(fsum).magnitude

assert_equal [[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]], Day18.final_sum([
    [[2, [[7, 7], 7]], [[5, 8], [[9, 3], [0, 2]]]],
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
])
assert_equal 3993, RootNode.from_array([[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]]).magnitude
assert_equal 3993, Day18.maximum_pair_sum(example_assignment)

puts "\nTests passed"

day18 = Day18.new(ARGF.map(&:chomp).freeze)
p part1: day18.part1
p part2: day18.part2
