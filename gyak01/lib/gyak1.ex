defmodule Head do
  def hd([x|_xs]), do: x
  def hd([]), do: nil
end
IO.puts(Head.hd([]) == nil)
IO.puts(Head.hd(Enum.to_list(1..5)) == 1)
IO.puts(Head.hd(~c"almárium") == ?a)



defmodule Tail do
  def tl([_x|xs]), do: xs
  def tl([]), do: nil
end
IO.puts(Tail.tl([]) == nil)
IO.puts(Tail.tl(Enum.to_list(1..5)) == [2,3,4,5])
IO.puts(Tail.tl(~c"almárium") == ~c"lmárium")



defmodule Nth do
  def nth([], _), do: nil
  def nth([h|_t], 0), do: h
  def nth([_h|t], n), do: nth(t, n - 1)
end
IO.puts(Nth.nth([], 5) == nil)
IO.puts(Nth.nth(Enum.to_list(1..5), 4) == 5)
IO.puts(Nth.nth(Enum.to_list(1..5), 5) == nil)
IO.puts(Nth.nth(~c"almárium", 3) == ?á)
IO.puts(Nth.nth(~c"almárium", -3) == nil)



defmodule Length do
  def len([h|t]), do: len([h|t], 0)
  def len([]), do: 0
  defp len([_h|t], acc), do: len(t, acc + 1)
  defp len([], acc), do: acc
end
IO.puts(Length.len([]) == 0)
IO.puts(Length.len(Enum.to_list(1..5)) == 5)
IO.puts(Length.len(~c"kőszerű") == 7)



defmodule Last do
  def last([_head|elements = [_second|_tail]]), do: last(elements)
  def last([head]), do: head
  def last([]), do: nil
end
IO.puts(Last.last(~c"Élvezed?") == ??)
IO.puts(Last.last([]))



defmodule Slice do
  def slice(_, 0, 0), do: []
  def slice([h|t], 0, n), do: [h|slice(t, 0, n - 1)]
  def slice([_h|t], k, n), do: slice(t, k - 1, n)
  def slice([], _, _), do: nil
end
IO.puts(Slice.slice([], 0, 5) == nil)
IO.puts(Slice.slice(Enum.to_list(1..5), 1, 3) == [2,3,4])
IO.puts(Slice.slice(Enum.to_list(1..5), 4, 1) == [5])
IO.inspect(Slice.slice(Enum.to_list(1..5), 4, 1))
IO.puts(Slice.slice(~c"almárium", 3, 3) == ~c"ári")
IO.puts(Slice.slice(~c"almárium", -3, 3) == nil)



defmodule Member do
  def member?([head|tail], element), do: if(head != element, do: member?(tail, element), else: true)
  def member?([], _), do: false
end
(Member.member?(~c"A szó elszáll", ?ó) == true) |> IO.inspect()
(Member.member?([~c"A szó", ~c"elszáll", ~c"az írás", ~c"megmarad."], ~c"elszáll")
== true) |> IO.inspect()
(Member.member?([1.2, ?v, "str", false], false) == true) |> IO.inspect()
(Member.member?([1.2, ?v, "str", false], "str") == true) |> IO.inspect()
(Member.member?([1.2, ?v, "str", false], ~c"str") == false) |> IO.inspect()
(Member.member?([], []) == false) |> IO.inspect()



defmodule Prime do
  def prime?(num)
end
