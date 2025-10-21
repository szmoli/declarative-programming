defmodule Nhf1 do
  @moduledoc """
  Számtekercs
  @author "Szmoleniczki Ákos <szmoleniczki.akos@edu.bme.hu>"
  @date   "2025-10-21"
  ...
  """
  @type size()  :: integer() # tábla mérete (0 < n)
  @type cycle() :: integer() # ciklus hossza (0 < m <= n)
  @type value() :: integer() # mező értéke (0 < v <= m)

  @type row()   :: integer()       # sor száma (1-től n-ig)
  @type col()   :: integer()       # oszlop száma (1-től n-ig)
  @type field() :: {row(), col()}  # mező koordinátái

  @type field_value() :: {field(), value()}                 # mező és értéke
  @type puzzle_desc() :: {size(), cycle(), [field_value()]} # feladvány

  @type retval()    :: integer()    # eredménymező értéke (0 <= rv <= m)
  @type solution()  :: [[retval()]] # egy megoldás
  @type solutions() :: [solution()] # összes megoldás

  @spec helix(sd::puzzle_desc()) :: ss::solutions()
  # ss az sd feladványleíróval megadott feladvány összes megoldásának listája
  def helix(sd) do

  end
end

defmodule Cyclists do
  @type size :: integer()
  @type cycle :: integer()
  @type length :: integer()
  @type field :: integer()
  @type value :: integer()
  @type constraints :: %{field() => value()}

  @spec from(
    n :: size(),
    m :: cycle(),
    len :: length(),
    constraints :: constraints()
  ) :: [[value()]]
  def from(n, m, len, constraints) do
    constraints = Map.new(constraints)
    zeros = len - n * m
    generate_lists(n, m, len, constraints, 1, 0, m, zeros, [], [])
  end

  @spec cycle_num(counter :: integer(), m :: cycle()) :: {cycle :: integer(), num :: value()}
  # megadja hogy éppen hanyadik ciklusban vagyunk és mi a következő szám a ciklusban
  defp cycle_num(counter, m) do
    cycle = div(counter, m) + 1
    num = rem(counter, m) + 1
    {cycle, num}
  end

  @spec candidates(ix :: integer(), zeros :: integer(), constraints :: constraints(), counter :: integer(), m :: cycle(), n :: size(), previous :: integer()) :: [integer()]
  # megadja a lehetséges számokat
  defp candidates(ix, zeros, constraints, counter, m, n, previous) do
    {cycle, num} = cycle_num(counter, m)
    candidate = Map.get(constraints, ix, num)
    constraint? = Map.has_key?(constraints, ix)
    zeros? = zeros > 0
    zero? = candidate == 0 and zeros?
    next_in_cycle? = candidate - previous == 1 and candidate != 0
    new_cycle? = candidate - previous == 1 - m and candidate != 0
    valid_cycle? = cycle <= n and (next_in_cycle? or new_cycle?)

    cands = cond do
      constraint? and zero? -> [0]
      constraint? and valid_cycle? -> [Map.get(constraints, ix)]
      constraint? and not valid_cycle? -> []
      zeros? and valid_cycle? -> [0, candidate]
      zeros? -> [0]
      valid_cycle? -> [candidate]
      true -> []
    end

    cands
  end

  @spec generate_lists(
    n :: size(), m :: size(), len :: length(),
    constraints :: constraints(), ix :: integer(),
    counter :: integer(), previous :: value(), zeros :: integer(),
    ls :: [value()], ls_acc :: [[value()]]
  ) :: [[value()]]
  defp generate_lists(_n, _m, len, _constraints, ix, _counter, _previous, _zeros, ls, ls_acc)
  when len == ix - 1 do
    [Enum.reverse(ls)|ls_acc]
  end
  defp generate_lists(n, m, len, constraints, ix, counter, previous, zeros, ls, ls_acc) do
    candidates(ix, zeros, constraints, counter, m, n, previous)
      |> Enum.reduce(ls_acc, fn candidate, acc ->
        new_zeros = if candidate == 0, do: zeros - 1, else: zeros
        new_counter = if candidate != 0, do: counter + 1, else: counter
        new_previous = if candidate != 0, do: candidate, else: previous
        new_ls = [candidate|ls]
        generate_lists(n, m, len, constraints, ix + 1, new_counter, new_previous, new_zeros, new_ls, acc)
    end)
  end
end

defmodule Helix do
  @type size :: integer()
  @type cycle :: integer()
  @type row :: integer()
  @type col :: integer()
  @type field :: {row(), col()}
  @type value :: integer()
  @type constraints :: %{field() => value()}
  @spec flatten(
    n :: size(),
    m :: cycle(),
    constraints :: constraints()
  ) :: [{field(), value()}]
  def flatten(n, m, constraints) do
    Enum.reverse(flatten(1, n, 1, n, constraints, []))
  end

  @spec flatten(top :: integer(), bottom :: integer(), left :: integer(), right :: integer(), constraints :: constraints(), acc :: [{field(), value()}]) :: [{field(), value()}]
  # Iteratívan bejárjuk a mátrixot a külső rétegtől befelé
  # finito
  defp flatten(top, bottom, left, right, field_values, acc) when bottom < top and right < left do
    acc
  end
  # 1x1
  defp flatten(top, bottom, left, right, field_values, acc) when bottom - top == 0 and right - left == 0 do
    field = {top, left}
    [Map.get(field_values, field) | acc]
  end
  # 2x2
  defp flatten(top, bottom, left, right, field_values, acc) when bottom - top == 1 and right - left == 1 do
    field1 = {top, left}
    field2 = {top, right}
    field3 = {bottom, right}
    field4 = {bottom, left}
    val1 = Map.get(field_values, field1)
    val2 = Map.get(field_values, field2)
    val3 = Map.get(field_values, field3)
    val4 = Map.get(field_values, field4)
    [val4|[val3|[val2|[val1|acc]]]]
  end
  # nagyobb
  defp flatten(top, bottom, left, right, field_values, acc) do
    acc =
      left..right
      |> Enum.reduce(acc, fn col, acc ->
        [Map.get(field_values, {top, col}) | acc]
      end)

    acc =
      (top + 1)..bottom
      |> Enum.reduce(acc, fn row, acc ->
        [Map.get(field_values, {row, right}) | acc]
      end)

    acc =
      (right - 1)..left
      |> Enum.reduce(acc, fn col, acc ->
        [Map.get(field_values, {bottom, col}) | acc]
      end)

    acc =
      (bottom - 1)..(top + 1)
      |> Enum.reduce(acc, fn row, acc ->
        [Map.get(field_values, {row, left}) | acc]
      end)

    flatten(top + 1, bottom - 1, left + 1, right - 1, field_values, acc)
  end
end
