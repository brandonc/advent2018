require 'set'

def sample_ops(input)
  samples = []

  input.each_slice(4) do |fixed, op, expect, _|
    fixed = fixed.strip
    op = op.strip
    expect = expect.strip

    break if fixed.empty? && op.empty?
    samples << {
      fixture: eval(fixed["Before: ".length..-1]),
      op: op,
      expect: eval(expect["After: ".length..-1])
    }
  end

  samples
end

def ops(input)
  input[sample_ops(input).size * 4 + 2..-1].map { |inst| inst.split(" ").map(&:to_i) }
end

$reg = nil

OPS = [
  -> (a, b, c) { $reg[c] = $reg[a] * $reg[b] }, # multr 0
  -> (a, b, c) { $reg[c] = $reg[a] == b ? 1 : 0 }, # eqri 1
  -> (a, _, c) { $reg[c] = $reg[a] }, # setr 2
  -> (a, b, c) { $reg[c] = $reg[a] == $reg[b] ? 1 : 0 }, #eqrr 3
  -> (a, b, c) { $reg[c] = $reg[a] > $reg[b] ? 1 : 0 }, # gtrr 4
  -> (a, b, c) { $reg[c] = $reg[a] * b }, # multi 5
  -> (a, b, c) { $reg[c] = $reg[a] | $reg[b] }, # borr 6
  -> (a, b, c) { $reg[c] = $reg[a] & b }, # bani 7
  -> (a, b, c) { $reg[c] = $reg[a] + $reg[b] }, # addr 8
  -> (a, b, c) { $reg[c] = $reg[a] & $reg[b] }, # banr 9
  -> (a, b, c) { $reg[c] = a == $reg[b] ? 1 : 0 }, # eqir 10
  -> (a, b, c) { $reg[c] = a > $reg[b] ? 1 : 0 }, # gtir 11
  -> (a, b, c) { $reg[c] = $reg[a] + b }, #addi 12
  -> (a, b, c) { $reg[c] = $reg[a] > b ? 1 : 0 }, # gtri 13
  -> (a, _, c) { $reg[c] = a }, # seti 14
  -> (a, b, c) { $reg[c] = $reg[a] | b }, # bori 15
]

def main
  input = ARGF.to_a

  tests = sample_ops(input).all? do |sample|
    op, a, b, c = sample[:op].split(" ").map(&:to_i)
    $reg = sample[:fixture].clone
    OPS[op].call(a, b, c)
    $reg == sample[:expect]
  end

  puts "Tests passed? #{tests}"

  $reg = [0, 0, 0, 0]
  ops(input).each do |op, a, b, c|
    OPS[op].call(a, b, c)
  end
  puts "Final registers: #{$reg.join(", ")}"
end

main
