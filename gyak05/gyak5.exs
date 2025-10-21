defmodule Tree do
  def most_right(:leaf) do
    :error
  end
  def most_right({val, _left, :leaf}) do
    {:ok, val}
  end
  def most_right({_val, _left, right}) do
    most_right(right)
  end

  def most_left(:leaf) do
    :error
  end
  def most_left({val, :leaf, _right}) do
    {:ok, val}
  end
  def most_left({_val, left, _right}) do
    most_left(left)
  end

  def in_order({val, left, right}) do
    in_order({val, left, right}, []) |> Enum.reverse
  end
  defp in_order(:leaf, acc) do
    acc
  end
  defp in_order({val, :leaf, :leaf}, acc) do
    [val|acc]
  end
  defp in_order({val, left, right}, acc) do
    acc = in_order(left, acc)
    acc = [val|acc]
    in_order(right, acc)
  end

  def ordered(tree) do
    values = in_order(tree)
    values == Enum.sort(values)
  end

  def routes({val, left, right}) do
    routes({val, left, right}, [], []) |> Enum.map(fn {val, route} -> {val, Enum.reverse(route)} end) |> Enum.reverse
  end
  defp routes(:leaf, route, route_acc) do
    route_acc
  end
  defp routes({val, :leaf, :leaf}, route, route_acc) do
    [{val, route}|route_acc]
  end
  defp routes({val, left, right}, route, route_acc) do
    route_acc = [{val, route}|route_acc]
    route = [val|route]
    route_acc = routes(left, route, route_acc)
    routes(right, route, route_acc)
  end

  def occurences(tree, val) do
    routes(tree) |> Enum.filter(fn {v, route} -> v == val end)
  end
end
