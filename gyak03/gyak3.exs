defmodule Lista do
  def dropevery([h | t], n), do: dropevery([h | t], n, 0)
  defp dropevery([], _n, _c), do: []

  defp dropevery([h | t], n, c) do
    list = dropevery(t, n, c + 1)

    if rem(c, n) != 0 do
      [h | list]
    else
      list
    end
  end

  def tails([]), do: [[]]

  def tails([h | t]) do
    list = tails(t)
    [[h | t] | list]
  end

  def pairs([]), do: []
  def pairs([_h]), do: []

  def pairs([h | [s | t]]) do
    list = pairs(t)
    [{h, s} | list]
  end

  def duplicates([]), do: []
  def duplicates([_h]), do: []

  def duplicates([h | [s | t]]) do
    list = duplicates([s | t])

    if h == s do
      [h | list]
    else
      list
    end
  end

  def repeated(ls), do: repeated(ls, 1)
  defp repeated([], _c), do: []
  defp repeated([_h], _c), do: []

  defp repeated(ls, c) when c < length(ls) do
    list = repeated(ls, c + 1)
    first = ls |> Enum.take(c)
    updated_ls = ls |> Enum.drop(c)
    second = updated_ls |> Enum.take(c)

    if first == second do
      [first | list]
    else
      list
    end
  end

  defp repeated(_ls, _c), do: []

  def stammering(ls), do: ls |> Lista.tails() |> Enum.flat_map(&Lista.repeated/1)

  def values_for(ls), do: for({:v, v} <- ls, do: v)

  def values([]), do: []
  def values([{:v, v} | t]), do: [v | values(t)]
  def values([_h | t]), do: values(t)
end

defmodule Szam do
  def proper_divisors(n) do
    for num <- 2..(n-1), rem(n, num) == 0, do: num
    # for(num <- 2..(n - 1), do: {num, rem(n, num)})
    # |> Enum.filter(fn {_num, rem} -> rem == 0 end)
    # |> Enum.map(fn {num, _rem} -> num end)
  end

  def composite_numbers(n) do
    for num <- 4..n, length(proper_divisors(num)) != 0, do: num
  end

  def composite?(n) do
    rem(n, 2) == 0 or length((for num <- 3..(:math.sqrt(num)), rem(n, num), do: num))
  end

  def composite_numbers_fast(n) do

  end
end
