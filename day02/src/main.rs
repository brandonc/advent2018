use std::io::{self, Read, BufRead};
use std::collections::{HashMap};

type CharCounts = HashMap<char, u32>;

fn main() {
    let mut cursor = cursor_from_reader();

    println!("Checksum of ids: {}", checksum_ids(&mut cursor));
    cursor.set_position(0);
    println!("Common ids of correct boxes: {}", common_ids(&mut cursor));
}

fn checksum_ids(reader: &mut io::BufRead) -> u32 {
    let mut twos = 0u32;
    let mut threes = 0u32;

    loop {
        let mut line = String::new();
        reader.read_line(&mut line).expect("reading from cursor won't fail");
        line.pop(); // Remove trailing newline

        if line.is_empty() {
            break;
        }

        let counts = count_letters(&line);
        if has_exact_repeating(&counts, 2) {
            twos += 1;
        }

        if has_exact_repeating(&counts, 3) {
            threes += 1;
        }
    }

    twos * threes
}

fn common_ids(reader: &mut BufRead) -> String {
    let ids = read_ids(reader);

    let perms = IdPermutation::new(&ids);

    for (a, b) in perms {
        match single_character_diff(&a, &b) {
            Some(index) => {
                let mut clone = a.clone();
                clone.remove(index);
                return clone;
            },
            _ => continue
        }
    }

    unreachable!()
}

fn has_exact_repeating(counts: &CharCounts, repeating: u32) -> bool {
    for (_, count) in counts {
        if *count == repeating {
            return true;
        }
    }
    false
}

fn count_letters(id: &String) -> CharCounts {
    let mut counts = CharCounts::new();

    for c in id.chars() {
        let counter = counts.entry(c).or_insert(0);
        *counter += 1;
    }

    counts
}

fn single_character_diff(a: &String, b: &String) -> Option<usize> {
    let mut diffs = 0;
    let mut result = 0;

    for index in 0..a.len() {
        if a.chars().nth(index).unwrap() != b.chars().nth(index).unwrap() {
            if diffs == 0 {
                result = index;
                diffs += 1;
            } else {
                return None;
            }
        }
    }

    Some(result)
}

fn cursor_from_reader() -> io::Cursor<String> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("no input");

    io::Cursor::new(input)
}

fn read_ids(reader: &mut io::BufRead) -> Vec<String> {
    let mut ids = Vec::new();

    loop {
        let mut line = String::new();
        reader.read_line(&mut line).expect("reading from cursor won't fail");

        if line.is_empty() {
            break;
        }

        line.pop(); // Remove trailing newline
        ids.push(line);
    }

    ids
}

struct IdPermutation<'a> {
    a: usize,
    b: usize,
    ids: &'a Vec<String>
}

impl<'a> IdPermutation<'a> {
    fn new(ids: &'a Vec<String>) -> IdPermutation<'a> {
        IdPermutation { a: 0, b: 0, ids: ids }
    }
}

impl<'a> Iterator for IdPermutation<'a> {
    type Item = (String, String);

    fn next(&mut self) -> Option<Self::Item> {
        if self.b < self.ids.len() - 1 {
            self.b += 1;
            Some((self.ids[self.a].clone(), self.ids[self.b].clone()))
        } else if self.a < self.ids.len() - 1 {
            self.a += 1;
            self.b = self.a + 1;

            if self.b >= self.ids.len() {
                None
            } else {
                Some((self.ids[self.a].clone(), self.ids[self.b].clone()))
            }
        } else {
            None
        }
    }
}
