defmodule Khf3 do
  @moduledoc """
  Ciklikus számlisták
  @author "Egyetemi Hallgató <egy.hallg@edu.bme.hu>"
  @date   "2025-10-xx"
  """
  # számsorozatok száma, n (1 < n)
  @type count() :: integer()
  # számsorozat hossza, m (1 <= m)
  @type cycle() :: integer()
  # listahossz, len (1 < len)
  @type size() :: integer()
  # listaelem értéke, val (0 <= val <= m)
  @type value() :: integer()
  # listaelem sorszáma, ix (1 <= ix <= len)
  @type index() :: integer()
  # listaelem indexe és értéke
  @type index_value() :: {index(), value()}

  @spec cyclists({n :: count(), m :: cycle(), len :: size()}, constraints :: [index_value()]) ::
          results :: [[value()]]
  # results az összes olyan len hosszú lista listája, melyekben
  # * az 1-től m-ig tartó számsorozat – ebben a sorrendben, esetleg
  #   közbeszúrt 0-kal – n-szer ismétlődik,
  # * len-n*m számú helyen 0-k vannak,
  # * a constraints korlát-listában felsorolt indexű cellákban a megadott
  #   értékű elemek vannak.
  def cyclists({n, m, len}, constraints) do
    # IO.inspect(constraints)
    # 0-tól kezdődő indexeléssé transzformálva
    constraints = Map.new(constraints, fn {ix, val} -> {ix - 1, val} end)
    # IO.inspect(constraints)
    zeros_available = len - n * m
    # 1..m -> (counter from 0 mod m) + 1
    # available = for num <- 1..m, do: num
    # IO.puts("len:")
    # IO.inspect(len)
    # cyclists({m, len}, constraints, start_ix, counter, zeros_count, ls_acc)
    generate_lists({n, m, len}, constraints, zeros_available, 0, 0, [], [])
  end

  defp possible_values(ix, num, constraints, zeros_available) do
    cond do
      Map.has_key?(constraints, ix) -> [Map.get(constraints, ix)]
      zeros_available > 0 -> [num, 0]
      true -> [num]
    end
  end

  # All zeros used and reached end of list -> done
  defp generate_lists({n, m, len}, constraints, zeros_available, ix, counter, current_list, list_acc)
    when ix == len and zeros_available == 0 do
      IO.puts "added list to accumulator"
      IO.inspect current_list
      IO.puts "-----------------"
      [Enum.reverse(current_list)|list_acc]
    end
  # Zeros remain but reached end of list -> invalid list
  defp generate_lists({n, m, len}, constraints, zeros_available, ix, counter, current_list, list_acc)
    when zeros_available < 0 or (ix == len and zeros_available != 0) do
      IO.puts "invalid list"
      IO.inspect current_list
      IO.puts "-----------------"
      list_acc
  end
  defp generate_lists({n, m, len}, constraints, zeros_available, ix, counter, current_list, list_acc) do
    # Process.sleep(2000)
    # IO.puts "ix:"
    # IO.inspect ix
    num = rem(counter, m) + 1 # repeating counter 1..m
    possibilities = possible_values(ix, num, constraints, zeros_available)
    # IO.puts "zeros available:"
    # IO.inspect zeros_available
    # IO.puts "possibilities:"
    # IO.inspect possibilities
    # IO.puts "current list:"
    # IO.inspect current_list
    Enum.reduce(possibilities, list_acc, fn val, acc ->
      new_zeros_available = if val == 0, do: zeros_available - 1, else: zeros_available
      new_counter = if val == 0, do: counter, else: counter + 1 # this is needed to keep the sequence correct when we use a zero
      new_current_list = [val|current_list]
      generate_lists({n, m, len}, constraints, new_zeros_available, ix + 1, new_counter, new_current_list, acc)
    end)
  end
end
