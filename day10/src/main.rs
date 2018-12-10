extern crate regex;

use std::io::{self, Read};
use regex::Regex;

struct Point {
    x: i32,
    y: i32,
    tx: i32,
    ty: i32
}

fn cursor_from_stdin() -> io::Cursor<String> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("no input");

    io::Cursor::new(input)
}

fn deserialize_input(reader: &mut io::BufRead) -> Vec<Point> {
    let pattern = Regex::new(r"^position=<\s*([-0-9]+),\s*([-0-9]+)> velocity=<\s*([-0-9]+),\s*([-0-9]+)>$").expect("valid regex");

    let mut result: Vec<Point> = Vec::new();

    loop {
        let mut line = String::new();
        reader.read_line(&mut line).expect("reading from cursor won't fail");

        if line.is_empty() {
            break;
        }

        let captures = pattern.captures(&line.trim()).unwrap();

        result.push(
            Point {
                x: captures[1].trim().parse::<i32>().expect("x captured an int"),
                y: captures[2].trim().parse::<i32>().expect("y captured an int"),
                tx: captures[3].trim().parse::<i32>().expect("tx captured an int"),
                ty: captures[4].trim().parse::<i32>().expect("ty captured an int"),
            }
        );
    }

    result
}

fn could_have_message(points: &Vec<Point>) -> bool {
    let ys: Vec<i32> = points.iter().map(|p| p.y).collect();
    let miny = ys.iter().min().expect("has input");
    let maxy = ys.iter().max().expect("has input");

    maxy - miny < 10
}

fn plot(points: &Vec<Point>) {
    let xs: Vec<i32> = points.iter().map(|p| p.x).collect();
    let ys: Vec<i32> = points.iter().map(|p| p.y).collect();

    let minx = xs.iter().min().expect("has input");
    let maxx = xs.iter().max().expect("has input");
    let miny = ys.iter().min().expect("has input");
    let maxy = ys.iter().max().expect("has input");

    let mut rows: Vec<Vec<char>> = Vec::with_capacity((maxy - miny) as usize);
    for _ in 0..=maxy - miny {
        let mut col: Vec<char> = Vec::with_capacity((maxx - minx) as usize);
        for _ in 0..=maxx - minx {
            col.push('.');
        }
        rows.push(col);
    }

    for p in points {
        rows[(p.y - miny) as usize][(p.x - minx) as usize] = '#';
    }

    for r in rows {
        for c in r {
            print!(" {}", c);
        }
        println!();
    }
}

fn predict_message(mut points: Vec<Point>) {
    let mut seconds = 0;
    let mut seen_messages = false;

    loop {
        if could_have_message(&points) {
            plot(&points);
            println!("this would have appeared after {} seconds", seconds);
            seen_messages = true;
        } else {
            if seen_messages {
                break;
            }
        }

        for p in points.iter_mut() {
            p.x += p.tx;
            p.y += p.ty;
        }

        seconds += 1;
    }
}

fn main() {
    let points = deserialize_input(&mut cursor_from_stdin());

    predict_message(points);
}
