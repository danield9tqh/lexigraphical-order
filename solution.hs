import Data.List
import System.Random

numbers :: Int -> Int -> [Int]
numbers max start = let
  current_level = takeWhile (<= max) [start..(first_nine start)]
  inbetweens x = numbers max (x * 10)
  in concatMap (\x -> x:(inbetweens x)) current_level

-- Takes a number and returns the first number after that ends with a 9
-- e.g. 55 -> 59, 110 -> 119
first_nine :: Int -> Int
first_nine x = (x `quot` 10) * 10 + 9

-- Given a range of integers (1..n) find the kth item when sorted in
-- in lexigraphical order
findKthNumber :: Int -> Int -> Int
findKthNumber n k = (numbers n 1)!!(k-1)

-- Converts the range of Ints into strings, sorts them in lexigraphical
-- order then takes the kth element. This is a slower but more reliable
-- function to test randomized test cases against
findKthNumberSlow :: Int -> Int -> Int
findKthNumberSlow n k = read ((Data.List.sort (map show [1..n]))!!(k-1))

-- (n, k, expected_result)
type TestCase = (Int, Int, Int)

-- generates a test case where n is in the range (begin, end) and then returns
-- the test case along with the new random generator seed
random_test_case :: RandomGen t => t -> (Int, Int) -> (TestCase, t)
random_test_case gen (begin, end) = let
  (randomN, new_gen1) = randomR (begin, end) gen
  (randomK, new_gen2) = randomR(begin, randomN) new_gen1
  in (
    (randomN, randomK, findKthNumberSlow randomN randomK),
    new_gen2
  )

-- creates a lazy list of test cases
random_test_cases :: RandomGen t => t -> (Int, Int) -> [TestCase]
random_test_cases gen range = let
  (next_example, next_gen) = random_test_case gen range
  in next_example:(random_test_cases next_gen range)

-- takes a test case of n, k and expected value and runs it against the 
-- findKthNumber function
run_test_case :: TestCase -> String
run_test_case (n, k, expected) = let
  actual = findKthNumber n k in
  if actual == expected
    then "Passed"
    else "Failed on: " ++ (show (n, k)) ++
         ", Expected: " ++ (show expected) ++
         ", Actual: " ++ (show actual)

manual_tests :: [TestCase]
manual_tests = [
  (10, 2, 10),
  (1, 1, 1),
  (9, 9, 9)]

-- instantiate and run manual and random test cases
main = do
  g <- newStdGen
  let random_tests = take 100 (random_test_cases g (1, 100000))
  let all_tests = random_tests ++ manual_tests
  mapM print (map run_test_case all_tests)