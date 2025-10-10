defmodule Khf3 do

  @moduledoc """
  Ciklikus számlisták
  @author "Egyetemi Hallgató <egy.hallg@edu.bme.hu>"
  @date   "2025-10-xx"
  """
  @type count() :: integer() # számsorozatok száma, n (1 < n)
  @type cycle() :: integer() # számsorozat hossza, m (1 <= m)
  @type size()  :: integer() # listahossz, len (1 < len)
  @type value() :: integer() # listaelem értéke, val (0 <= val <= m)
  @type index() :: integer() # listaelem sorszáma, ix (1 <= ix <= len)
  @type index_value() :: {index(), value()} # listaelem indexe és értéke

  # @spec cyclists({n::count(), m::cycle(), len::size()}, constraints::[index_value()]) :: results::[[value()]]
  # results az összes olyan len hosszú lista listája, melyekben
  # * az 1-től m-ig tartó számsorozat – ebben a sorrendben, esetleg
  #   közbeszúrt 0-kal – n-szer ismétlődik,
  # * len-n*m számú helyen 0-k vannak,
  # * a constraints korlát-listában felsorolt indexű cellákban a megadott
  #   értékű elemek vannak.
  # def cyclists({n, m, len}, constraints)

  def cycle_num(counter, m) do
    cycle = div(counter, m) + 1
    num = rem(counter, m) + 1
    {cycle, num}
  end

  def candidates(ix, zeros, constraints, counter, m) do
    constraint = Map.get(constraints, ix)
    {_, num} = cycle_num(counter, m)
    cond do
      constraint -> [constraint]
      zeros > 0 -> [num, 0]
      true -> [num]
    end
  end

  def valid_candidate?(cand, previous, ix, constraints, zeros, m) do
    next_in_cycle? = cand - previous == 1 and cand != 0
    new_cycle? = cand - previous == 1 - m and cand != 0
    zero? = cand == 0
    zeros? = zeros > 0
    constraint? = Map.has_key?(constraints, ix)

    cond do
      constraint? && zero? -> zeros?
      constraint? -> cand == Map.get(constraints, ix)
      (next_in_cycle? or new_cycle?) and not zero? -> true
      zero? -> zeros?
      true -> false
    end
  end
end
