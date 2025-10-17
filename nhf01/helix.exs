defmodule Nhf1 do
  @moduledoc """
  Számtekercs
  @author "Szmoleniczki Ákos <szmoleniczki.akos@edu.bme.hu>"
  @date   "2025-10-24"
  ...
  """
  # tábla mérete (0 < n)
  @type size() :: integer()
  # ciklus hossza (0 < m <= n)
  @type cycle() :: integer()
  # mező értéke (0 < v <= m)
  @type value() :: integer()

  # sor száma (1-től n-ig)
  @type row() :: integer()
  # oszlop száma (1-től n-ig)
  @type col() :: integer()
  # mező koordinátái
  @type field() :: {row(), col()}

  # mező és értéke
  @type field_value() :: {field(), value()}
  # feladvány
  @type puzzle_desc() :: {size(), cycle(), [field_value()]}

  # eredménymező értéke (0 <= rv <= m)
  @type retval() :: integer()
  # egy megoldás
  @type solution() :: [[retval()]]
  # összes megoldás
  @type solutions() :: [solution()]

  @spec helix(sd :: puzzle_desc()) :: ss :: solutions()
  # ss az sd feladványleíróval megadott feladvány összes megoldásának listája
  def helix({n, m, _}) when n < m, do: []
  def helix(sd) do
    {n, m, constraints} = sd
    constraints_map = Map.new(constraints) # field => value
    solution_map = Map.new(constraints)
    zeros = n - m
    helix_solutions(n, 1, n, 1, n, constraints_map)
  end

  @type row() :: [retval()]
  @type solution() :: [row()]
  @type zeros() :: integer() # 0 <= zeros, number of available zeros
  @spec helix_solution(
    n :: size(),
    top :: row(), bottom :: row(),
    left :: col(), right :: col(),
    zeros :: zeros(),
    counter :: cycle(),
    solution :: solution() # current solution
  ) :: [solution()]
  # 1 x 1
  defp helix_solution(n, top, bottom, left, right, constraints) when bottom - top == 0 and left - right == 0 do
    nil
  end
  # 2 x 2
  defp helix_solutions(n, top, bottom, left, right, constraints) when bottom - top == 1 and left - right == 1 do
    nil
  end
  # nagyobb tábla
  defp helix_solutions(n, top, bottom, left, right, constraints) do
    rows = for row_ix <- top..bottom, do: table_row(n, row_ix, constraints)
    cols = for col_ix <- top..bottom, do: table_col(n, col_ix, constraints)
    IO.inspect rows, label: "rows"
    IO.inspect cols, label: "cols"
    # top row

    # right column

    # bottom row

    # left column
    nil
  end

  @spec table_row(n :: size(), row_ix :: row(), constraints :: constraints())
  def table_row(n, row_ix, constraints) do
    { :row,
      (for i <- 1..n, into: %{} do
        field = {row_ix, i}
        {field, Map.get(constraints, field)}
      end)}
  end

  @spec table_col(n :: size(), col_ix :: col(), constraints :: constraints()) :: {atom(), [{field(), integer()}]}
  def table_col(n, col_ix, constraints) do
    { :col,
      (for i <- 1..n, into: %{} do
        field = {i, col_ix}
        {field, Map.get(constraints, field)}
      end)}
  end

  @spec cycle_number(n :: size(), m :: cycle(), counter :: integer()) :: {integer(), cycle()}
  def cycle_number(n, m, counter) do
    cycle = div(counter, m) + 1
    num = rem(counter, m) + 1
    {cycle, num}
  end

  def candidates()

  def valid_candidate?()

  def cyclists()
end
