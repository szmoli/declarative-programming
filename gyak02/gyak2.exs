# ZH-hoz hasonló feladatok: főleg csúszóablakos
defmodule UptoBy3 do
  def upto_by_3(n) do
    upto_by_3(n, 1)
  end

  defp upto_by_3(n, counter) do
    if rem(counter, 3) == 0 do
      IO.puts counter
    end
    if counter < n do
      upto_by_3(n, counter + 1)
    end
  end

  def upto_by_3_left(n) do
    upto_by_3_left(n, 1)
  end

  defp upto_by_3_left(n, counter) do
    if counter < n do
      upto_by_3(n, counter + 1)
    end

    if rem(counter, 3) == 0 do
      IO.puts counter
    end
  end
end

defmodule Lista do
  def split([], _n), do: {[], []}
  def split([h|t], n) do
    {l1, l2} = split(t, n - 1)
    if n > 0 do
      {[h|l1], l2}
    else
      {l1, [h|l2]}
    end
  end

  def takewhile([], _f), do: []
  def takewhile([h|t], f) do
    l = takewhile(t, f)
    if (f.(h)) do
      [h|l]
    else
      l
    end
  end

  def dropevery(l, n) do
    dropevery(l, n, 0)
  end
  defp dropevery([], _n, _counter), do: []
  defp dropevery([h|t], n, counter) do
    l = dropevery(t, n, counter + 1)
    if (rem(counter, n) != 0) do
      [h|l]
    else
      l
    end
  end

  def pairs([]), do: []
  def pairs([h]), do: []
  def pairs([h|[s|t]]) do
    l = pairs(t)
    [{h,s}|l]
  end

  def parosan([]), do: []
  def parosan([h]), do: [h]
  def parosan([h|[s|t]]) do
  end
end
