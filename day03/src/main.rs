extern crate regex;

use regex::Regex;
use std::io::{self, Read};
use std::iter;

struct ClaimData {
    id: i32,
    top: i32,
    left: i32,
    width: i32,
    height: i32
}

struct FabricData {
    ids: Vec<i32>
}

const FABRIC_SIZE: usize = 1000;

impl Clone for FabricData {
    fn clone(&self) -> FabricData {
        FabricData { ids: self.ids.clone() }
    }
}

impl ClaimData {
    pub fn from_string(raw: &String) -> ClaimData {
        let pattern = Regex::new(r"^#(?P<id>[0-9]+)\s@\s(?P<left>[0-9]+),(?P<top>[0-9]+):\s(?P<width>[0-9]+)x(?P<height>[0-9]+)$")
                        .expect("this is a valid regex");

        let captures = pattern.captures(raw).unwrap();

        ClaimData {
            id: captures.name("id").expect("regex captures").as_str().parse::<i32>().expect("id captured an int"),
            top: captures.name("top").expect("regex captures").as_str().parse::<i32>().expect("top captured an int"),
            left: captures.name("left").expect("regex captures").as_str().parse::<i32>().expect("left captured an int"),
            width: captures.name("width").expect("regex captures").as_str().parse::<i32>().expect("width captured an int"),
            height: captures.name("height").expect("regex captures").as_str().parse::<i32>().expect("height captured an int"),
        }
    }
}

fn layout_claims(claims: &Vec<ClaimData>, fabric: &mut Fabric) {
    for claim in claims {
        for x in claim.left..claim.left + claim.width {
            for y in claim.top..claim.top + claim.height {
                fabric[x as usize][y as usize].ids.push(claim.id);
            }
        }
    }
}

fn main() {
    let mut fabric = initialize_fabric();
    let claims = read_claims(&mut cursor_from_reader());

    layout_claims(&claims, &mut fabric);

    println!(
        "{} in² are used by more than one claim",
        total_overlapping_claims(&fabric)
    );

    println!(
        "The non-overlapping claim is {}",
        find_nonoverlapping_claim(&claims, &fabric)
            .expect("input contains non-overlapping claim")
    );
}

fn total_overlapping_claims(fabric: &Fabric) -> i32 {
    let mut total = 0;
    for x in 0..FABRIC_SIZE {
        for y in 0..FABRIC_SIZE {
            if fabric[x as usize][y as usize].ids.len() > 1 {
                total += 1;
            }
        }
    }

    total
}

fn find_nonoverlapping_claim(claims: &Vec<ClaimData>, fabric: &Fabric) -> Option<i32> {
    for claim in claims {
        let mut no_overlap = true;
        for x in claim.left..claim.left + claim.width {
            for y in claim.top..claim.top + claim.height {
                if fabric[x as usize][y as usize].ids.len() > 1 {
                    no_overlap = false;
                    break;
                }
            }
            if !no_overlap {
                break;
            }
        }
        if no_overlap {
            return Some(claim.id);
        }
    }

    return None;
}

type Fabric = Vec<Vec<FabricData>>;

fn initialize_fabric() -> Fabric {
    let mut result: Fabric = vec![];
    let row = iter::repeat(FabricData { ids: Vec::new() }).take(FABRIC_SIZE).collect::<Vec<_>>();
    for _ in 0..FABRIC_SIZE {
        result.push(row.clone());
    }

    result
}

fn cursor_from_reader() -> io::Cursor<String> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("no input");

    io::Cursor::new(input)
}

fn read_claims(reader: &mut io::BufRead) -> Vec<ClaimData> {
    let mut claims = Vec::new();

    loop {
        let mut line = String::new();
        reader.read_line(&mut line).expect("reading from cursor won't fail");

        if line.is_empty() {
            break;
        }

        line.pop(); // Remove trailing newline

        claims.push(ClaimData::from_string(&line));
    }

    claims
}
