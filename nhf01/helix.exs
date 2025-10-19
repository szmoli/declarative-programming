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
    list_zeros = n - m
    helix_solutions(n, m, 1, n, 1, n, constraints_map, constraints_map)
  end

  @type zeros() :: integer() # 0 <= zeros, number of available zeros
  @type constraints() :: %{field() => value()}
  @spec helix_solution(
    n :: size(), m :: cycle(),
    top :: row(), bottom :: row(),
    left :: col(), right :: col(),
    # zeros :: zeros(),
    # counter :: cycle(),
    constraints :: constraints(),
    solution :: solution() # current solution
  ) :: [solution()]
  # 1 x 1
  defp helix_solution(n, m, top, bottom, left, right, constraints, solution) when bottom - top == 0 and left - right == 0 do
    nil
  end
  # 2 x 2
  defp helix_solutions(n, m, top, bottom, left, right, constraints, solution) when bottom - top == 1 and left - right == 1 do
    nil
  end
  # nagyobb tábla
  defp helix_solutions(n, m, top, bottom, left, right, constraints, solution) do
    {rows, cols} = table(n, top, bottom, left, right, constraints)

    IO.inspect solution, label: "start"

    # Top row
    cyclists(m, n, row_constraints(top, solution))
      |> Enum.reduce(solution, fn values, acc ->
        solution = values
          |> Enum.with_index
          |> Map.new(fn {value, index} -> {{top, index + 1}, value} end)
          |> Map.merge(solution)

        IO.inspect solution, label: "after top row"

        cyclists(m, n, col_constraints(right, solution))
          |> Enum.reduce(solution, fn values, acc ->
            solution = values
              |> Enum.with_index
              |> Map.new(fn {value, index} -> {{index + 1, right}, value} end)
              |> Map.merge(solution)

            IO.inspect solution, label: "after right col"
          end)
      end)

    # Right col

  end

  def row_constraints(row_ix, constraints) do
    constraints |> Map.new(fn {{row_ix, col}, val} -> {col, val} end)
  end

  def col_constraints(col_ix, constraints) do
    constraints |> Map.new(fn {{row, col_ix}, val} -> {row, val} end)
  end

  def table(n, top, bottom, left, right, constraints) do
    rows = for row_ix <- top..bottom, into: %{}, do: {row_ix, table_row(n, row_ix, constraints)}
    cols = for col_ix <- left..right, into: %{}, do: {col_ix, table_col(n, col_ix, constraints)}
    {rows, cols}
  end

  @spec table_row(n :: size(), row_ix :: row(), constraints :: constraints()) :: [{field(), integer()}]
  def table_row(n, row_ix, constraints) do
    for i <- 1..n, into: %{} do
      field = {row_ix, i}
      {field, Map.get(constraints, field)}
    end
  end

  @spec table_col(n :: size(), col_ix :: col(), constraints :: constraints()) :: [{field(), integer()}]
  def table_col(n, col_ix, constraints) do
    for i <- 1..n, into: %{} do
      field = {i, col_ix}
      {field, Map.get(constraints, field)}
    end
  end

  # --------
  # Cyclists
  # --------

  @type count() :: integer() # számsorozatok száma, n (1 < n)
  @type index() :: integer() # listaelem sorszáma, ix (1 <= ix <= len)
  @type index_value() :: {index(), value()} # listaelem indexe és értéke

  @spec cyclists(m :: cycle(), len :: size(), constraints::[index_value()]) :: results::[[value()]]
  # results az összes olyan len hosszú lista listája, melyekben
  # * az 1-től m-ig tartó számsorozat – ebben a sorrendben, esetleg
  #   közbeszúrt 0-kal – n-szer ismétlődik,
  # * len-n*m számú helyen 0-k vannak,
  # * a constraints korlát-listában felsorolt indexű cellákban a megadott
  #   értékű elemek vannak.
  def cyclists(m, len, constraints) do
    constraints = Map.new(constraints)
    zeros = len - m
    generate_lists(m, len, constraints, 1, 0, m, zeros, [], [])
  end

  @spec cycle_num(counter :: integer(), m :: cycle()) :: {cycle :: integer(), num :: value()}
  # megadja hogy éppen hanyadik ciklusban vagyunk és mi a következő szám a ciklusban
  defp cycle_num(counter, m) do
    cycle = div(counter, m) + 1
    num = rem(counter, m) + 1
    {cycle, num}
  end

  @spec candidates(ix :: integer(), zeros :: integer(), constraints :: constraints(), counter :: integer(), m :: cycle(), previous :: integer()) :: [integer()]
  # megadja a lehetséges számokat
  defp candidates(ix, zeros, constraints, counter, m, previous) do
    {cycle, num} = cycle_num(counter, m)
    candidate = Map.get(constraints, ix, num)
    constraint? = Map.has_key?(constraints, ix)
    zeros? = zeros > 0
    zero? = candidate == 0 and zeros?
    next_in_cycle? = candidate - previous == 1 and candidate != 0
    new_cycle? = candidate - previous == 1 - m and candidate != 0
    valid_cycle? = cycle <= 1 and (next_in_cycle? or new_cycle?)

    cands = cond do
      constraint? and zero? -> [0]
      constraint? and valid_cycle? -> [Map.get(constraints, ix)]
      constraint? and not valid_cycle? -> []
      zeros? and valid_cycle? -> [0, candidate]
      zeros? -> [0]
      valid_cycle? -> [candidate]
      true -> []
    end

    IO.inspect cands, label: "candidates"

    cands
  end

  @spec generate_lists(m :: cycle(), len :: size(), constraints :: constraints(), ix :: index(), counter :: integer(), previous :: integer(), zeros :: integer(), ls :: [value()], ls_acc :: [[value()]]) :: [[value()]]
  defp generate_lists(_m, len, _constraints, ix, _counter, _previous, _zeros, ls, ls_acc)
  when len == ix - 1 do
    [Enum.reverse(ls)|ls_acc]
  end
  defp generate_lists(m, len, constraints, ix, counter, previous, zeros, ls, ls_acc) do
    candidates(ix, zeros, constraints, counter, m, previous)
      |> Enum.reduce(ls_acc, fn candidate, acc ->
        new_zeros = if candidate == 0, do: zeros - 1, else: zeros
        new_counter = if candidate != 0, do: counter + 1, else: counter
        new_previous = if candidate != 0, do: candidate, else: previous
        new_ls = [candidate|ls]
        generate_lists(m, len, constraints, ix + 1, new_counter, new_previous, new_zeros, new_ls, acc)
    end)
  end
end
