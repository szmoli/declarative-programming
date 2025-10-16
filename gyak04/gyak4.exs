defmodule Plains do
  # ugyanolyan elem
  defp chunk(element, [element]) do
    {:cont, [element|[element]]}
  end
  defp chunk(element, [element|tail]) do
    {:cont, [element|[element|tail]]}
  end
  # átmenet nem ugyanolyan elemek közt
  defp chunk(element, acc) when length(acc) >= 2 do
    {:cont, acc, [element]}
  end
  defp chunk(element, acc) do
    {:cont, [element]}
  end
  defp rest(acc) when length(acc) >= 2, do: {:cont, acc, []}
  defp rest(acc), do: {:cont, []}
  def of(ls) do
    Enum.chunk_while(ls, [], &chunk/2, &rest/1)
  end
end

defmodule Smallers do
  defp chunk(el, []) do
    {:cont, [el]}
  end
  defp chunk(el, [prev|tail]) when el < prev do
    {:cont, [el|[prev|tail]]}
  end
  defp chunk(el, [prev|tail]) do
    {:cont, tl(Enum.reverse([prev|tail])), [el]}
  end
  defp rest(acc), do: {:cont, tl(Enum.reverse(acc)), []}
  def of(ls) do
    List.flatten(Enum.chunk_while(ls, [], &chunk/2, &rest/1))
  end
end
