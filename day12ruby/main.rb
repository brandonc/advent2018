require "set"

rules = Set.new(["#.#.#",
                 ".#.##",
                 "##...",
                 "##..#",
                 "#.##.",
                 ".#..#",
                 "###.#",
                 ".#...",
                 "##.#.",
                 "#..##",
                 "####.",
                 "###..",
                 "##.##",
                 "..###",
                 "...##"].map { |r| r.split("") })

initial = "##.#...#.#.#....###.#.#....##.#...##.##.###..#.##.###..####.#..##..#.##..#.......####.#.#..#....##.#".split("")

def regenerate(current, rules)
  result = current.dup
  for i in current.min - 3..current.max
    slice = [".", ".", ".", ".", "."].map.with_index do |c, index|
      current.include?(index + i) ? "#" : "."
    end

    if rules.include?(slice)
      result.add(i + 2)
    else
      result.delete(i + 2)
    end
  end

  result
end

def plot(set, n)
  print "%2.2s. " % n
  for i in set.min..set.max
    print set.include?(i) ? "#" : "."
  end
  puts
end

generation = Set.new
initial.each.with_index do |c, index|
  generation << index if c == "#"
end

20.times do |index|
  generation = regenerate(generation, rules)
  plot(generation, index + 1)
end

puts
puts generation.reduce(&:+)
