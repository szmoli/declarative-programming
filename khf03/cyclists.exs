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

  defp log_hash(n, m, len, constraints) do
    :crypto.hash(:sha256, inspect({n, m, len, constraints})) |> Base.encode16()
  end

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
    hash = log_hash(n, m, len, constraints)
    File.rm("logs/invalid_lists_#{hash}.txt")
    File.rm("logs/valid_lists_#{hash}.txt")
    # IO.inspect {n, m, len, constraints}, label: "start params"
    File.write("logs/valid_lists_#{hash}.txt", "#{inspect({n, m, len, constraints})}\n\n", [:append])
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
    # IO.puts "candidates:"
    # IO.inspect cands, label: "candidates"

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
      constraint? and zero? -> {:zero, zeros?}
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
  defp generate_lists({n, m, len}, constraints, ix, _counter, _previous, _zeros, ls, ls_acc)
  when len == ix do
    hash = log_hash(n, m, len, constraints)
    # if valid_list?(n, m, ls) do
      # IO.puts "valid list"
      # IO.inspect ls, label: "valid list"
      File.write("logs/valid_lists_#{hash}.txt", "#{inspect(Enum.reverse(ls))}\n", [:append])
      [Enum.reverse(ls)|ls_acc]
    # else
      # IO.inspect ls, label: "invalid list"
    #  File.write("logs/invalid_lists_#{hash}.txt", "#{inspect(Enum.reverse(ls))}\n", [:append])
      # IO.puts "invalid list"
      # IO.inspect ls
    #  ls_acc
    #end
  end
  defp generate_lists({n, m, len}, constraints, ix, counter, previous, zeros, ls, ls_acc) do
    # IO.puts ""
    # IO.puts "ls:"
    # IO.inspect ls, label: "list"
    # Process.sleep(2000)
    candidates(ix, zeros, constraints, counter, m, n, previous)
      |> Enum.reduce(ls_acc, fn candidate, acc ->
        # {type, valid?} = valid_candidate?(candidate, previous, ix, constraints, zeros, m)
        # if valid? do
          new_zeros = if candidate == 0, do: zeros - 1, else: zeros
          new_counter = if candidate != 0, do: counter + 1, else: counter
          new_previous = if candidate != 0, do: candidate, else: previous
          new_ls = [candidate|ls]
          generate_lists({n, m, len}, constraints, ix + 1, new_counter, new_previous, new_zeros, new_ls, acc)
        # else
        #  acc
        #end
    end)
    # candidates(ix, zeros, constraints, counter, m, n, previous)
    #   |> Enum.reduce(ls_acc, fn candidate, acc ->
    #     {type, valid?} = valid_candidate?(candidate, previous, ix, constraints, zeros, m)
    #     if valid? do
    #       new_zeros = if type == :zero, do: zeros - 1, else: zeros
    #       new_counter = if type != :zero, do: counter + 1, else: counter
    #       new_previous = if type != :zero, do: candidate, else: previous
    #       new_ls = [candidate|ls]
    #       generate_lists({n, m, len}, constraints, ix + 1, new_counter, new_previous, new_zeros, new_ls, acc)
    #     else
    #       acc
    #     end
    # end)
  end
end
