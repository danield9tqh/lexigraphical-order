use rand::prelude::*;

// Represents a range of numbers in lexigraphical order base 10.
//      max  - maximum in the total lexigraphical range
//      curr - the current item the iterator is on
//      end  - the end of that specific iterator e.g. an iterator might go from 110 - 119 with
//             sub-iterators inbetween
//      curr_inbetween - the current sub-iterator. e.g. leixgraphical order might be
//             1, 10, 11, 12, 19, .., 2. In this case 10 - 19 would be provided by
//             a sub-iterator of 1-9
struct Numbers {
    max: u64,
    curr: u64,
    end: u64,
    curr_inbetween: Box<Option<Numbers>>
}

impl Iterator for Numbers {
    type Item = u64;

    fn next(&mut self) -> Option<u64> {
        if self.curr > self.max || self.curr > self.end {
            None
        } else {
            match &mut *self.curr_inbetween {
                Some(inbetween) => {
                    match inbetween.next() {
                        Some(x) => {
                            Some(x)
                        } None => {
                            self.curr += 1;
                            self.curr_inbetween = Box::new(None);
                            self.next()
                        }
                    }
                },
                None => {
                    self.curr_inbetween = Box::new(Some(Numbers {
                        max: self.max,
                        curr: self.curr*10,
                        end: self.curr*10 + 9,
                        curr_inbetween: Box::new(None)
                    }));
                    Some(self.curr)
                }
            }
        }
    }
}

fn find_kth_number(n: u64, k: u64) -> u64 {
    let mut numbers = Numbers{max: n, curr: 1, end: 9, curr_inbetween: Box::new(None)};
    numbers.nth((k-1) as usize).unwrap()
}

fn find_kth_number_slow(n: u64, k: u64) -> u64 {
    let mut range = (1..=n).map(|x| x.to_string()).collect::<Vec<String>>();
    range.sort();
    range.get((k-1) as usize).unwrap().parse::<u64>().unwrap()
}

fn random_test_cases(num_cases: u64, n_max: u64) -> Vec<(u64, u64, u64)> {
    let mut rng = thread_rng();
    (1..num_cases).map(|_| {
        let n = rng.gen_range(1..=n_max);
        let k = rng.gen_range(1..=n);
        let expected = find_kth_number_slow(n, k);
        (n, k, expected)
    }).collect()
}

fn main() {
    let manual_tests: Vec<(u64, u64, u64)> = vec![
        (10, 2, 10),
        (1, 1, 1),
        (9, 9, 9)];

    // Run some test cases with smaller n. N is between (1, 10)
    let smaller_cases = random_test_cases(100, 10);

    // Run some test cases with medium n. N is between (1, 100)
    let medium_cases = random_test_cases(100, 100);

    // Run some test cases with larger n. N is between (1, 10000)
    let large_cases = random_test_cases(100, 10000);

    let all_cases = manual_tests.iter()
                    .chain(smaller_cases.iter())
                    .chain(medium_cases.iter())
                    .chain(large_cases.iter());

    for (n, k, expected) in all_cases {
        let actual = find_kth_number(*n, *k);
        assert_eq!(actual, *expected, "failed at n:{} k:{} actual:{} expected:{}", *n, *k, actual, *expected)
    }
}