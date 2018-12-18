TILE_OPEN = "."
TILE_TREE = "|"
TILE_YARD = "#"

def parse_input(raw)
  result = Array.new(raw.length) { Array.new(raw[0].length - 1) }

  raw.each.with_index do |row, y|
    break if row.strip.length == 0
    row.strip.each_char.with_index do |tile, x|
      result[y][x] = tile
    end
  end

  result
end

def adjacencies(map, x, y)
  result = Hash.new(0)
  for xx in (x-1..x+1)
    for yy in (y-1..y+1)
      if (xx == x && yy == y) || xx < 0 || xx >= map[0].length || yy < 0 || yy >= map.length
        next
      else
        result[map[yy][xx]] += 1
      end
    end
  end
  result
end

def total(map)
  result = Hash.new(0)
  map.each.with_index do |row, y|
    row.each.with_index do |tile, x|
      result[map[y][x]] += 1
    end
  end
  result
end

def tick(map)
  result = Array.new(map[0].length) { Array.new(map.length) }

  map.each.with_index do |row, y|
    row.each.with_index do |tile, x|
      adj = adjacencies(map, x, y)

      if map[y][x] == TILE_OPEN
        result[y][x] = adj[TILE_TREE] >= 3 ? TILE_TREE : TILE_OPEN
      elsif map[y][x] == TILE_TREE
        result[y][x] = adj[TILE_YARD] >= 3 ? TILE_YARD : TILE_TREE
      elsif map[y][x] == TILE_YARD
        result[y][x] = adj[TILE_YARD] > 0 && adj[TILE_TREE] > 0 ? TILE_YARD : TILE_OPEN
      end
    end
  end

  result
end

def plot(map)
  map.each do |row|
    puts row.join("")
  end
  puts ""
end

def main
  map = parse_input(ARGF.to_a)

  10.times do
    map = tick(map)
  end

  t = total(map)
  puts "resource value = #{t[TILE_TREE] * t[TILE_YARD]}"
end

main
