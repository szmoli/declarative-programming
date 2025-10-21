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
    _solution_map = Map.new(constraints)
    _list_zeros = n - m
    reset_log(n, m, constraints)
    #helix_solutions(n, m, 1, n, 1, n, constraints_map, constraints_map)
    helix_solutions(n, m, 1, n, 1, n, constraints_map, constraints_map, [])
  end

  def log_file(n, m, _constraints) do
    hash = :crypto.hash(:sha, inspect({n, m})) |> Base.encode16
    "logs/helix_#{hash}.txt"
  end
  def reset_log(n, m, constraints), do: log_file(n, m, constraints) |> File.rm
  def write_log(str, n, m, constraints), do: log_file(n, m, constraints) |> File.write("#{str}\n", [:append])

  @type zeros() :: integer() # 0 <= zeros, number of available zeros
  @type constraints() :: %{field() => value()}
  @spec helix_solutions(
    n :: size(), m :: cycle(),
    top :: row(), bottom :: row(),
    left :: col(), right :: col(),
    constraints :: constraints(),
    solution :: solution(), # current solution
    solutions :: [solution()]
  ) :: [solution()]
  # defp helix_solutions(n, m, top, bottom, left, right, constraints, solution, solutions)
  # when bottom < top or right < left do
  #   "solution accepted: #{inspect(solution)}" |> write_log(n,m,constraints)
  #   [solution|solutions]
  # end

  # finish valid
  defp helix_solutions(n, m, top, bottom, left, right, constraints, solution, solutions)
  when map_size(solution) == n * n and bottom < top  and right < left do
    IO.inspect solution, label: "solution accepted"
    "solution accepted: #{inspect(solution)}" |> write_log(n,m,constraints)
    [solution|solutions]
  end
  # finish invalid
  defp helix_solutions(n, m, top, bottom, left, right, constraints, solution, solutions)
  when map_size(solution) != n * n and bottom < top and right < left do
    IO.inspect solution, label: "solution rejected"
    "solution rejected: #{inspect(solution)}" |> write_log(n,m,constraints)
    solutions
  end
  # nagyobb tábla
  defp helix_solutions(n, m, top, bottom, left, right, constraints, solution, solutions) do
    #IO.inspect solution, label: "start"
    "\nn, top, bottom, left, right: #{inspect({n, top, bottom, left, right})}" |> write_log(n,m,constraints)
    "guards: #{bottom < top or right < left}" |> write_log(n, m, constraints)
    inspect(solution) |> write_log(n, m, constraints)

    first_layer? = top == 1 and bottom == n and left == 1 and right == n
    solve_row(top, n, m, first_layer?, solution, [])
    |> Enum.reduce(solutions, fn constraints, acc ->
      solve_col(right, n, m, true, constraints, [])
      |> Enum.reduce(acc, fn constraints, acc ->
        solve_row(bottom, n, m, true, constraints, [])
        |> Enum.reduce(acc, fn constraints, acc ->
          solve_col(left, n, m, true, constraints, [])
          |> Enum.reduce(acc, fn constraints, acc ->
            helix_solutions(n, m, top + 1, bottom - 1, left + 1, right - 1, constraints, constraints, acc)
          end)
        end)
      end)
    end)
  end

  def solve_row(row_ix, n, m, first_any?, constraints, row_solutions) do
    cyclists(m, n, row_constraints(row_ix, constraints), first_any?)
    |> Enum.reduce(row_solutions, fn values, acc ->
      IO.inspect values, label: "values"
      inspect(values) |> write_log(n, m ,constraints)

      solution = values
      |> Enum.with_index
      |> Map.new(fn {value, index} -> {{row_ix, index + 1}, value} end)

      [solution|acc]
    end)
  end

  def solve_col(col_ix, n, m, first_any?, constraints, col_solutions) do
    cyclists(m, n, col_constraints(col_ix, constraints), first_any?)
    |> Enum.reduce(col_solutions, fn values, acc ->
      IO.inspect values, label: "values"
      inspect(values) |> write_log(n, m ,constraints)

      solution = values
      |> Enum.with_index
      |> Map.new(fn {value, index} -> {{index + 1, col_ix}, value} end)

      [solution|acc]
    end)
  end

  def row_constraints(row_ix, constraints) do
    rc = constraints |> Enum.filter(fn {{row, _col}, _val} -> row == row_ix end) |> Map.new(fn {{_, col}, val} -> {col, val} end)
#    IO.inspect {row_ix, rc}, label: "row constraints"
    rc
  end

  def col_constraints(col_ix, constraints) do
    cc = constraints |> Enum.filter(fn {{_row, col}, _val} -> col == col_ix end)|> Map.new(fn {{row, _}, val} -> {row, val} end)
#    IO.inspect {col_ix, cc}, label: "col constraints"
    cc
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

  @spec cyclists(m :: cycle(), len :: size(), constraints::constraints(), start_any? :: boolean()) :: results::[[value()]]
  # results az összes olyan len hosszú lista listája, melyekben
  # * az 1-től m-ig tartó számsorozat – ebben a sorrendben, esetleg
  #   közbeszúrt 0-kal – n-szer ismétlődik,
  # * len-n*m számú helyen 0-k vannak,
  # * a constraints korlát-listában felsorolt indexű cellákban a megadott
  #   értékű elemek vannak.
  def cyclists(m, len, constraints, start_any?) do
    zeros = len - m
    # IO.inspect constraints, label: "constraints"
    IO.inspect {m, len, constraints}, label: "start params"
    generate_lists(m, len, constraints, 1, m, zeros, [], [], start_any?)
  end

  @spec cycle_num(number :: integer(), m :: cycle()) :: value()
  # megadja hogy éppen hanyadik ciklusban vagyunk és mi a következő szám a ciklusban
  def cycle_num(number, m) do
    rem(number - 1, m) + 1
  end

  @spec candidates(ix :: integer(), zeros :: integer(), constraints :: constraints(), m :: cycle(), previous :: integer(), next :: integer(), first_any? :: boolean()) :: [integer()]
  # megadja a lehetséges számokat
  defp candidates(ix, zeros, constraints, m, previous, next, first_any?) do
    next = cycle_num(next, m)
    candidate = Map.get(constraints, ix, next)
    constraint? = Map.has_key?(constraints, ix)
    zeros? = zeros > 0
    zero? = candidate == 0 and zeros?
    next_in_cycle? = candidate - previous == 1 and candidate != 0
    new_cycle? = candidate - previous == 1 - m and candidate != 0
    valid_cycle? = (next_in_cycle? or new_cycle? or ix == 1)
    use_every_value? = ix == 1 and first_any?

    # IO.inspect {candidate, previous, next}, label: "candidate, previous, next"

    cands = cond do
      constraint? and zero? -> [0]
      constraint? and valid_cycle? -> [Map.get(constraints, ix)]
      constraint? and not valid_cycle? -> []
      use_every_value? and zeros? -> [0|Enum.to_list(1..m)]
      use_every_value? -> Enum.to_list(1..m)
      zeros? and valid_cycle? -> [0, candidate]
      zeros? -> [0]
      valid_cycle? -> [candidate]
      true -> []
    end

    # IO.inspect cands, label: "candidates"

    cands
  end

  @spec generate_lists(m :: cycle(), len :: size(), constraints :: constraints(), ix :: index(), previous :: integer(), zeros :: integer(), ls :: [value()], ls_acc :: [[value()]], first_any? :: boolean()) :: [[value()]]
  defp generate_lists(_m, len, _constraints, ix, _previous, zeros, ls, ls_acc, _first_any?)
  when len == ix - 1 and zeros == 0 do
    # IO.inspect Enum.reverse(ls), label: "added ls"
    [Enum.reverse(ls)|ls_acc]
  end
  defp generate_lists(_m, len, _constraints, ix, _previous, zeros, _ls, ls_acc, _first_any?)
  when len == ix - 1 and zeros > 0 do
    # IO.inspect Enum.reverse(ls), label: "not added ls"
    ls_acc
  end
  # defp generate_lists(_m, len, _constraints, ix, _previous, _zeros, ls, ls_acc), do: ls_acc
  defp generate_lists(m, len, constraints, ix, previous, zeros, ls, ls_acc, first_any?) do
    # IO.inspect Enum.reverse(ls), label: "ls"

    # start = previous + 1
    # start..m
    # |> Enum.to_list
    # |> Enum.reduce(ls_acc, fn next, acc ->
    # start = if zeros > 0, do: 0, else: 1
    # numbers = if ix == 1, do: Enum.to_list(start..m), else: candidates(ix, zeros, constraints, m, previous, previous + 1)

    # numbers
    candidates(ix, zeros, constraints, m, previous, previous + 1, first_any?)
    |> Enum.reduce(ls_acc, fn candidate, acc ->
      new_zeros = if candidate == 0, do: zeros - 1, else: zeros
      new_previous = if candidate != 0, do: candidate, else: previous
      new_ls = [candidate|ls]
      generate_lists(m, len, constraints, ix + 1, new_previous, new_zeros, new_ls, acc, true)
    end)
  end

  # defp generate_lists(m, len, constraints, ix, previous, zeros, ls, ls_acc, false) do
  #   # IO.inspect Enum.reverse(ls), label: "ls"

  #   # start = previous + 1
  #   # start..m
  #   # |> Enum.to_list
  #   # |> Enum.reduce(ls_acc, fn next, acc ->
  #   candidates(ix, zeros, constraints, m, previous, previous + 1)
  #   |> Enum.reduce(ls_acc, fn candidate, acc ->
  #     new_zeros = if candidate == 0, do: zeros - 1, else: zeros
  #     new_previous = if candidate != 0, do: candidate, else: previous
  #     new_ls = [candidate|ls]
  #     generate_lists(m, len, constraints, ix + 1, new_previous, new_zeros, new_ls, acc, true)
  #   end)
  # end
end

defmodule DebugModule do
  # Version 1: With guard
  def test_guard(n, top, bottom, left, right, mp)
  when map_size(mp) == (n * n) and bottom < top  and right < left do
    IO.puts "GUARD MATCHED"
    {:guard_matched, n, top, bottom, left, right, mp}
  end

  # Version 2: Without guard (catch-all)
  def test_guard(n, top, bottom, left, right, mp) do
    IO.puts "GUARD NOT MATCHED"
    IO.inspect(map_size(mp), label: "map_size(mp)")
    IO.inspect(n * n, label: "n * n")
    IO.inspect(bottom - top, label: "bottom - top")
    IO.inspect(right - left, label: "right - left")
    IO.inspect(map_size(mp) == n * n, label: "size_match?")
    IO.inspect(bottom < top, label: "vertical_cond?")
    IO.inspect(right < left, label: "horizontal_cond?")
    {:guard_not_matched, n, top, bottom, left, right, mp}
  end
end
