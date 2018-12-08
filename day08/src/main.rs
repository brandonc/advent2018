use std::io::{self, Read};
use std::collections::VecDeque;

fn sum_metadata(input: &mut VecDeque<i32>) -> i32 {
    let mut sum = 0;

    let children = input.pop_front().expect("invalid input");
    let metas = input.pop_front().expect("invalid input");

    for _ in 0..children {
        sum += sum_metadata(input);
    }

    for _ in 0..metas {
        sum += input.pop_front().expect("invalid input");
    }

    sum
}

fn child_node_value(metas: &[i32], child_sums: &[i32]) -> i32 {
    let mut value = 0;
    for m in metas.iter() {
        if *m > 0 && *m <= child_sums.len() as i32 {
            value += child_sums[(*m - 1) as usize];
        }
    }

    value
}

fn node_value(input: &mut VecDeque<i32>) -> i32 {
    let children = input.pop_front().expect("invalid input");
    let metas = input.pop_front().expect("invalid input");

    let mut child_sums = Vec::<i32>::new();
    let mut meta_values = Vec::<i32>::new();

    for _ in 0..children {
        child_sums.push(node_value(input));
    }

    for _ in 0..metas {
        meta_values.push(input.pop_front().expect("invalid input"));
    }

    if children == 0 {
        meta_values.iter().fold(0, |acc, v| acc + v)
    } else {
        child_node_value(&meta_values[..], &child_sums[..])
    }
}

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("can read from stdin");

    let tree: VecDeque<i32> = input.split(" ")
                                      .map(|c| c.trim().parse::<i32>().expect("input is i32"))
                                      .collect();

    println!("Sum of metadata is {}", sum_metadata(&mut tree.clone()));
    println!("Value of root is {}", node_value(&mut tree.clone()));
}
