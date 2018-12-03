FABRIC_SIZE = 1000

CLAIM_PATTERN = /^#(?<id>[0-9]+)\s@\s(?<left>[0-9]+),(?<top>[0-9]+):\s(?<width>[0-9]+)x(?<height>[0-9]+)$/

fabric = Array.new(FABRIC_SIZE) { Array.new(FABRIC_SIZE) { Array.new } }

def deserialize_claim(raw)
  match = raw.match(CLAIM_PATTERN)
  return nil unless match
  {
    id: match[:id].to_i,
    left: match[:left].to_i,
    top: match[:top].to_i,
    width: match[:width].to_i,
    height: match[:height].to_i
  }
end

claims = ARGF.to_a.map { |line| deserialize_claim(line) }.compact

claims.each do |claim|
  for x in claim[:left]...(claim[:left] + claim[:width])
    for y in claim[:top]...(claim[:top] + claim[:height])
      fabric[x][y].push(claim[:id])
    end
  end
end

sq_inches_overlapped = 0
for x in 0...FABRIC_SIZE
  for y in 0...FABRIC_SIZE
    sq_inches_overlapped += 1 if fabric[x][y].size > 1
  end
end

puts "#{sq_inches_overlapped} in² are within 2 or more claims"

claims.each do |claim|
  next_id = false

  for x in claim[:left]...(claim[:left] + claim[:width])
    for y in claim[:top]...(claim[:top] + claim[:height])
      if fabric[x][y].size > 1
        next_id = true
        break
      end
    end
    break if next_id
  end

  if !next_id
    puts "#{claim[:id]} is a claim that does not overlap"
    break
  end
end

