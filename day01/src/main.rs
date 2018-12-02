use std::io::{self, Read};
use std::collections::HashSet;

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("no input");

    let mut cursor = io::Cursor::new(input);

    println!("final frequency: {}", sum_lines(&mut cursor));
    println!("first repeated frequency: {}", first_repeated(&mut cursor));
}

fn next_integer(buffer: &mut io::BufRead) -> Option<i32> {
    let mut input = String::new();
    buffer.read_line(&mut input).expect("Could not read lines!");

    if input.is_empty() {
        None
    } else if input.trim().is_empty() {
        next_integer(buffer)
    } else {
        Some(input.trim().parse::<i32>().unwrap())
    }
}

fn sum_lines(buffer: &mut io::BufRead) -> i32 {
    let mut current: i32 = 0;

    loop {
        match next_integer(buffer) {
            Some(n) => current += n,
            None => break
        }
    }

    current
}

fn first_repeated(cursor: &mut io::Cursor<String>) -> i32 {
    let mut seen: HashSet<i32> = HashSet::new();
    let mut current: i32 = 0;

    loop {
        cursor.set_position(0);

        loop {
            match next_integer(cursor) {
                Some(n) => {
                    current += n;
                    if !seen.insert(current) {
                        return current;
                    }
                }
                None => break
            }
        }
    }
}

#[test]
fn test_processing() {
    let mut s = io::Cursor::new("+12\n-10\n-10\n-10\n");
    assert_eq!(sum_lines(&mut s), -18);
}

#[test]
fn test_newlines_and_whitespace() {
    let mut s = io::Cursor::new("+12\n -5 \n\n-3");
    assert_eq!(sum_lines(&mut s), 4);
}

#[test]
fn test_repeat_detection() {
    let mut s = io::Cursor::new("+3\n+3\n+4\n-2\n-4".to_string());
    assert_eq!(first_repeated(&mut s), 10);
}
