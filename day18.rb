#!/usr/bin/env ruby
# frozen_string_literal: true

class TreeNode
  attr_accessor :left, :right, :parent

  def ==(other)
    return false if other.class != TreeNode
    return false if leaf? != other.leaf?

    left == other.left && right == other.right
  end

  def inspect
    return "#{left.inspect}" if leaf?

    "[#{left.inspect},#{right.inspect}]"
  end
  alias to_s inspect

  def leaf?
    right.nil?
  end

  def self.from_array(value)
    case value
    in [l, r]
      TreeNode.add(from_array(l), from_array(r))
    else
      TreeNode.new(value, nil, nil)
    end
  end

  def self.add(left, right)
    raise StandardError, "has parent: #{left.inspect}" unless left.parent.nil?
    raise StandardError, "has parent: #{right.inspect}" unless right.parent.nil?

    left.parent = right.parent = TreeNode.new(left, right, nil).tap { |tn| tn.reduce! }
  end

  def split!
    return false unless leaf?
    return false unless left >= 10

    q, r = left.divmod(2)
    self.left = TreeNode.new(q, nil, self)
    self.right = TreeNode.new(q + r, nil, self)
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
      lix = lnodes.find_index { |n| n.object_id === explod.left.object_id }
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
    return false if leaf?
    parent_depth == 4
  end

  def parent_depth
    return 0 if parent.nil?
    1 + parent.parent_depth
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

  def initialize(left, right, parent)
    if right.nil?
      raise StandardError, "not integer: #{left.inspect} (#{left.class})" unless left.class == Integer
    end
    @left = left
    @right = right
    @parent = parent
    yield self if block_given?
  end
end

class Day18
  def part1
    arr = lines.map { |line| eval(line) } # DIRRRTY eval
    Day18.final_sum(arr).magnitude
  end

  def part2; end

  def self.add(left, right)
    TreeNode.add(
      TreeNode.from_array(left),
      TreeNode.from_array(right)
    )
  end

  def self.add_all(arr)
    arr.map(&TreeNode.method(:from_array)).reduce(&TreeNode.method(:add))
  end

  def self.split(num)
    TreeNode.new(num, nil, nil).tap { |tn| tn.split! }
  end

  def self.split_once(arr)
    add_all(arr).tap(&:split_once!)
  end

  def self.explode_once(arr)
    add_all(arr).tap(&:explode_once!)
  end

  def self.magnitude(arr)
    TreeNode.new(add_all(arr).magnitude, nil, nil)
  end

  def self.final_sum(arr)
    arr
      .map(&TreeNode.method(:from_array))
      .reduce { |prev, node|
        tn = TreeNode.add(prev, node)
        tn.reduce!
        tn
      }
  end

  private

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end
end

class AssertionError < StandardError; end

def assert(msg = 'Assertion failed')
  raise AssertionError, msg unless yield

  printf '.'
end

def assert_equal(expected, actual)
  expected = TreeNode.from_array(expected)
  assert("\nExpect #{expected.inspect}\nActual #{actual.inspect}") { expected == actual }
end

assert_equal [1, 2], TreeNode.from_array([1, 2])
assert("Identity equals") { TreeNode.from_array([1, 2]).object_id !=
                            TreeNode.from_array([1, 2]).object_id }
assert_equal [[1, 2], [[3, 4], 5]], Day18.add([1, 2], [[3, 4], 5])
assert_equal [[[[1, 1], [2, 2]], [3, 3]], [4, 4]], Day18.add_all(
  [
    [1, 1],
    [2, 2],
    [3, 3],
    [4, 4]
  ]
)
assert_equal 9, Day18.split(9)
assert_equal [5, 5], Day18.split(10)
assert_equal [5, 6], Day18.split(11)
assert_equal [6, 6], Day18.split(12)

assert_equal [9, 3], Day18.split_once([9, 3]) # nothing over 10 -> don't split anything
assert_equal [[5, 5], 3], Day18.split_once([10, 3])
assert_equal [[5, 5], 11], Day18.split_once([10, 11]) # only split leftmost value
assert_equal [[9, [5, 5]], 11], Day18.split_once([[9, 10], 11]) # only split leftmost value

assert_equal 29, Day18.magnitude([9, 1])
assert_equal 21, Day18.magnitude([1, 9])
assert_equal 129, Day18.magnitude([[9, 1], [1, 9]])
assert_equal 143, Day18.magnitude([[1, 2], [[3, 4], 5]])
assert_equal 1384, Day18.magnitude([[[[0, 7], 4], [[7, 8], [6, 0]]], [8, 1]])
assert_equal 445, Day18.magnitude([[[[1, 1], [2, 2]], [3, 3]], [4, 4]])
assert_equal 791, Day18.magnitude([[[[3, 0], [5, 3]], [4, 4]], [5, 5]])
assert_equal 1137, Day18.magnitude([[[[5, 0], [7, 4]], [5, 5]], [6, 6]])
assert_equal 3488, Day18.magnitude([[[[8, 7], [7, 7]], [[8, 6], [7, 7]]], [[[0, 7], [6, 6]], [8, 7]]])

assert_equal [5, [7, 2]], Day18.explode_once([5, [7, 2]]) # no explosion
assert_equal [[[[0, 9], 2], 3], 4], Day18.explode_once([[[[[9, 8], 1], 2], 3], 4])
assert_equal [7, [6, [5, [7, 0]]]], Day18.explode_once([7, [6, [5, [4, [3, 2]]]]])
assert_equal [[6, [5, [7, 0]]], 3], Day18.explode_once([[6, [5, [4, [3, 2]]]], 1])
assert_equal [[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]],
             Day18.explode_once([[3, [2, [1, [7, 3]]]], [6, [5, [4, [3, 2]]]]])
assert_equal [[3, [2, [8, 0]]], [9, [5, [7, 0]]]], Day18.explode_once([[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]])

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
assert_equal 4140, Day18.magnitude(fsum)

puts "\nTests passed"

day18 = Day18.new(ARGF.map(&:chomp).freeze)
p part1: day18.part1
p part2: day18.part2
