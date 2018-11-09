-- https://leetcode.com/problems/k-th-smallest-in-lexicographical-order/

numbers n start = let
  ten_numbers = takeWhile (< n) [start..(to_first_nine start)]
  inbetweeens = map (\x -> numbers n (x * 10)) ten_numbers
  in join_inbetweens ten_numbers inbetweeens

to_first_nine x = (x `quot` 10) * 10 + 9

join_inbetweens []     []           = []
join_inbetweens (x:xs) (list:lists) = let
  front = x:list
  in front ++ join_inbetweens xs lists

findKthNumber n k = (numbers n 1)!!(k-1)

main = print (findKthNumber 1000300005 43232)
