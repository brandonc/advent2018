class CircularLinkedList
  class Node
    attr_reader :value
    attr_accessor :next, :prev

    def initialize(value)
      @value = value
    end
  end

  attr_reader :head, :tail

  def initialize
    @head = Node.new(0)
    @head.next = @head
    @head.prev = @head
  end

  def remove(old)
    tn = old.next
    tp = old.prev
    old.prev.next = tn
    old.next.prev = tp
    old
  end

  def insert(after, value)
    n = Node.new(value)
    tmp = after.next
    n.prev = after
    n.next = tmp
    after.next = n
    tmp.prev = n
    n
  end
end

def play(players, points)
  scores = Array.new(players, 0)
  game = CircularLinkedList.new
  current = game.head
  current_player = 0

  for m in 1...points
    current = if m % 23 == 0
      next_current = current.prev.prev.prev.prev.prev.prev
      old = game.remove(next_current.prev)
      scores[current_player] += m + old.value
      next_current
    else
      game.insert(current.next, m)
    end

    current_player = (current_player + 1) % players
  end

  scores.max
end

def test_examples
  puts play(9, 25) == 32
  puts play(10, 1618) == 8317
  puts play(13, 7999) == 146373
  # puts play(17, 1104) == 2764 // this is wrong as far as I can tell
  puts play(21, 6111) == 54718
  puts play(30, 5807) == 37305
end

test_examples

# This was my input
puts "part1: #{play(479, 71035)}"
puts "part1: #{play(479, 71035 * 100)}"
