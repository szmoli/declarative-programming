defmodule Khf3 do

  @moduledoc """
  Ciklikus számlisták
  @author "Szmoleniczki Ákos <szmoleniczki.akos@edu.bme.hu>"
  @date   "2025-10-10"
  """
  @type count() :: integer() # számsorozatok száma, n (1 < n)
  @type cycle() :: integer() # számsorozat hossza, m (1 <= m)
  @type size()  :: integer() # listahossz, len (1 < len)
  @type value() :: integer() # listaelem értéke, val (0 <= val <= m)
  @type index() :: integer() # listaelem sorszáma, ix (1 <= ix <= len)
  @type index_value() :: {index(), value()} # listaelem indexe és értéke

  @spec cyclists({n::count(), m::cycle(), len::size()}, constraints::[index_value()]) :: results::[[value()]]
  # results az összes olyan len hosszú lista listája, melyekben
  # * az 1-től m-ig tartó számsorozat – ebben a sorrendben, esetleg
  #   közbeszúrt 0-kal – n-szer ismétlődik,
  # * len-n*m számú helyen 0-k vannak,
  # * a constraints korlát-listában felsorolt indexű cellákban a megadott
  #   értékű elemek vannak.
  def cyclists({n, m, len}, constraints) do
    constraints = Map.new(constraints, fn {ix, val} -> {ix - 1, val} end)
    zeros = len - n * m
    generate_lists({n, m, len}, constraints, 0, 0, m, zeros, [], [])
  end

  @spec cycle_num(counter :: integer(), m :: cycle()) :: {cycle :: integer(), num :: value()}
  # megadja hogy éppen hanyadik ciklusban vagyunk és mi a következő szám a ciklusban
  defp cycle_num(counter, m) do
    cycle = div(counter, m) + 1
    num = rem(counter, m) + 1
    {cycle, num}
  end

  @type constraints :: %{ integer() => integer() }
  @spec candidates(ix :: integer(), zeros :: integer(), constraints :: constraints(), counter :: integer(), m :: cycle()) :: [integer()]
  # megadja a lehetséges számokat
  defp candidates(ix, zeros, constraints, counter, m) do
    constraint = Map.get(constraints, ix)
    {_, num} = cycle_num(counter, m)
    cands = cond do
      constraint -> [constraint]
      zeros > 0 -> [num, 0]
      true -> [num]
    end
    # IO.puts "candidates:"
    # IO.inspect cands

    cands
  end

  @spec valid_candidate?(cand :: integer(), previous :: integer(), ix :: index(), constraints :: constraints(), zeros :: integer(), m :: cycle()) :: {type :: atom(), valid? :: boolean()}
  # megadja hogy a lehetséges szám érvényes-e vagy sem
  defp valid_candidate?(cand, previous, ix, constraints, zeros, m) do
    next_in_cycle? = cand - previous == 1 and cand != 0
    new_cycle? = cand - previous == 1 - m and cand != 0
    zero? = cand == 0
    zeros? = zeros > 0
    constraint? = Map.has_key?(constraints, ix)

    {type, valid?} = cond do
      constraint? && zero? -> {:zero, zeros?}
      constraint? -> {:constraint, cand == Map.get(constraints, ix) and (next_in_cycle? or new_cycle?)}
      (next_in_cycle? or new_cycle?) and not zero? -> {:number, true}
      zero? -> {:zero, zeros?}
      true -> {:number, false}
    end
    # IO.puts "candidate:"
    # IO.inspect {cand, type, valid?}

    {type, valid?}
  end

  @spec valid_list?(n :: count(), m :: cycle(), ls :: [integer()]) :: boolean()
  # megadja hogy a lista érvényes-e
  defp valid_list?(n, m, ls) do
    {zeros, non_zeros} = ls
      |> Enum.split_with(fn val -> val == 0 end)
    # IO.inspect {non_zeros, zeros}

    cycles_ok? = non_zeros
      |> Enum.frequencies()
      |> Enum.all?(fn {_val, count} -> count == n end)
    zeros_ok? = length(zeros) == length(ls) - n * m
    # IO.inspect {length(zeros), length(ls) - n * m}
    # IO.inspect cycles_ok?
    # IO.inspect zeros_ok?

    cycles_ok? and zeros_ok?
  end

  @spec generate_lists({n :: count(), m :: cycle(), len :: size()}, constraints :: constraints(), ix :: index(), counter :: integer(), previous :: integer(), zeros :: integer(), ls :: [value()], ls_acc :: [[value()]]) :: [[value()]]
  defp generate_lists({n, m, len}, _constraints, ix, _counter, _previous, _zeros, ls, ls_acc)
  when len == ix do
    if valid_list?(n, m, ls) do
      # IO.puts "valid list"
      # IO.inspect ls
      [Enum.reverse(ls)|ls_acc]
    else
      # IO.puts "invalid list"
      # IO.inspect ls
      ls_acc
    end
  end
  defp generate_lists({n, m, len}, constraints, ix, counter, previous, zeros, ls, ls_acc) do
    # IO.puts ""
    # IO.puts "ls:"
    # IO.inspect ls
    candidates(ix, zeros, constraints, counter, m)
      |> Enum.reduce(ls_acc, fn candidate, acc ->
        {type, valid?} = valid_candidate?(candidate, previous, ix, constraints, zeros, m)
        if valid? do
          new_zeros = if type == :zero, do: zeros - 1, else: zeros
          new_counter = if type != :zero, do: counter + 1, else: counter
          new_previous = if type != :zero, do: candidate, else: previous
          new_ls = [candidate|ls]
          generate_lists({n, m, len}, constraints, ix + 1, new_counter, new_previous, new_zeros, new_ls, acc)
        else
          acc
        end
    end)
  end
end
