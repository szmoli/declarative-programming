# Helix Solver Documentation

## Problem specification

The program is given a `n * n` table described by the number `n`. A cycle of number `1 .. m` described be the number `m` and optional `v` value constraints for specific fields of the table. From these parameters the program needs to calculate all possible `rv` values for every cell of the `n * n` table where all the below conditions are met.

## Requirements and conditions

### Parameters

- `0 < n`
- `0 < m <= n`
- `0 < v <= m`
- `0 <= rv <= m`

### Helix traversal

The `n * n` table is traversed in a helix fashion:

1. Traversal starts from the top left corner of the table to the right direction
2. When the top right corner is reached
3. Then traversal continues downwards
4. When the bottom right corner is reached
5. Then traversal continues to the left direction
6. When the bottom left corner is reached
7. Then traversal continues upwards
8. When the field below the top left corner is reached
9. Then traversal continues on the next inside layer of the table
10. When the last field is reached and there's no more layers to the table
11. Then the traversal is finished.

### Rows and columns of the table

All rows and columns of every solution table must contain the `rv` values `0 .. m` exactly once increasing in the order of the Helix traversal specified above. If no value can be used for the `rv` value from the `1 .. m` range, then `rv` must be a `0` value.

### Solution table

The program returns a list of each possible solution table for the given problem. The solution tables are lists of its rows. The rows are lists of `rv` values.

## Computing the solutions

The general idea behind the algorithm is to use the knowledge gained from implementing the previous homeworks' algorithms.

### Cyclists (homework 3)

We can use the cyclists algorithm implemented in homework 3 to generate all possible solutions of a single row or column in a given table by passing it the current solution's constraints which are updated as the traversal unfolds, the size of the tabel's current layer and the cycle.

### Helix flatten (homework 2)

The basic idea behind the helix flattening algorithm can be used to call the cyclists algorithm in the correct order for the rows and columns of the table.

