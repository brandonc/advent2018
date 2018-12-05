use std::io::{self, Read};

fn main() {
    let input = read_input();
    println!(
        "reaction resulted in {} units",
        polymer_react(&input, None).chars().count()
    );

    println!(
        "best reaction after filtering was {} units",
        best_reaction(&input)
    );
}

fn reactable(a: u8, b: u8) -> bool {
    (a as i32 - b as i32).abs() == 32
}

fn strip_char(chain: &mut Vec<u8>, c: char) {
    let mut i = 0;
    let al = c.to_ascii_lowercase() as u8;
    let au = c.to_ascii_uppercase() as u8;

    loop {
        if chain.len() <= i {
            break;
        }

        if chain[i] == al || chain[i] == au {
            chain.remove(i);
        } else {
            i += 1;
        }
    }
}

fn polymer_react(input: &str, strip: Option<char>) -> String {
    let mut chain: Vec<u8> = input.as_bytes().to_vec();

    if strip.is_some() {
        strip_char(&mut chain, strip.unwrap());
    }

    let mut reacted = true;
    while reacted {
        reacted = false;
        let mut i = 0;
        loop {
            if chain.len() <= i + 1 {
                break;
            }

            if reactable(chain[i], chain[i + 1]) {
                chain.remove(i);
                chain.remove(i);
                reacted = true;
                if i > 0 {
                    i -= 1
                }
            } else {
                i += 1
            }
        }
    }

    String::from_utf8(chain).expect("has chars")
}

fn best_reaction(input: &str) -> usize {
    let mut best = input.chars().count();
    for c in "abcdefghijklmnopqrstuvwxyz".chars() {
        let try = polymer_react(input, Some(c)).chars().count();
        if try < best {
            best = try;
        }
    }
    best
}

fn read_input() -> String {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("no input");

    // trim newline
    if input.chars().last().expect("input has chars") == '\n' {
        input.pop();
    }

    input
}

#[test]
fn test_empty_result() {
    let output = polymer_react(&"abBA".to_string(), None);
    assert_eq!(&output[..], "");
}

#[test]
fn test_10_result() {
    let output = polymer_react(&"dabAcCaCBAcCcaDA".to_string(), None);
    assert_eq!(&output[..], "dabCBAcaDA");
}

#[test]
fn test_no_reaction() {
    let output = polymer_react(&"aabAAB".to_string(), None);
    assert_eq!(&output[..], "aabAAB");
}

#[test]
fn test_no_reaction_odd_number() {
    let output = polymer_react(&"aabAA".to_string(), None);
    assert_eq!(&output[..], "aabAA");
}
