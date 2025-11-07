defmodule T1 do
  def f(i, xs) do
    # @spec f1(xs :: [any()]) :: rs :: [any()]
    # Az xs lista hárommal *nem* osztható indexű elemeiből álló lista zs, az
    # elemek eredeti sorrendjében. Indexelés 0-tól. Az xs lista üres is lehet. (3 pont)
    f1 = fn xs ->
      xs |> Enum.with_index |> Enum.filter(fn {_, ix} -> rem(ix, 3) != 0 end) |> Enum.map(fn {v, _} -> v end)
    end

    # @spec f2(coll :: [integer()] | Range.t()) :: s :: integer()
    # A coll számlista vagy tartomány páros értékű elemeinek összege s (3 pont)
    f2 = fn coll ->
      coll |> Enum.filter(fn x -> rem(x, 2) == 0 end) |> Enum.sum()
    end

    # @spec f3(xs::[integer()]) :: n::integer()
    # Az xs lista monoton növekvő elemekből álló, lehető leghosszabb prefixuma n
    # hosszú. Azaz xs első n eleme monoton növekvő sorozatot alkot, és az xs vagy
    # pontosan n elemből áll, vagy az (n+1)-edik eleme kisebb az előtte
    # állónál. Feltételezheti, hogy xs nem üres. (4 pont)
    f3 = fn xs ->
      [_|t] = xs
      {pref, _} = Enum.zip(xs, t) |> Enum.split_while(fn {cur, next} -> cur <= next end)
      length(pref)
    end

    case i do
      1 -> f1.(xs)
      2 -> f2.(xs)
      3 -> f3.(xs)
    end
  end
end

IO.puts "T1"
(T1.f(1, [1,-4,5,6,"5",-3,12,11,7,4]) === [-4,5,"5",-3,11,7]) |> IO.inspect()
(T1.f(1, [:a,4]) === [4]) |> IO.inspect()
(T1.f(1, [:b]) === []) |> IO.inspect()
(T1.f(1, [0,:c,-1]) === [:c,-1]) |> IO.inspect()
(T1.f(1, []) === []) |> IO.inspect()
(T1.f(2, 1..10 // 1) === 30) |> IO.inspect()
(T1.f(2, 10..1 // -3) === 14) |> IO.inspect()
(T1.f(2, [-7, -4, -2, -1, 0, 4, 9, 12, 14, 17, 26]) === 50) |> IO.inspect()
(T1.f(3, [6]) === 1) |> IO.inspect()
(T1.f(3, [6, 7, 8, 6, 7, 8, 6, 7, 9]) === 3) |> IO.inspect()
(T1.f(3, [2, 2, 2, 3, 3, 3]) === 6) |> IO.inspect()

(T1.f(1, [1,-4,5,6,"5",-3,12,11,7,4]) ) |> IO.inspect()
(T1.f(1, [:a,4]) ) |> IO.inspect()
(T1.f(1, [:b]) ) |> IO.inspect()
(T1.f(1, [0,:c,-1]) ) |> IO.inspect()
(T1.f(1, []) ) |> IO.inspect()
(T1.f(2, 1..10 // 1) ) |> IO.inspect()
(T1.f(2, 10..1 // -3) ) |> IO.inspect()
(T1.f(2, [-7, -4, -2, -1, 0, 4, 9, 12, 14, 17, 26]) ) |> IO.inspect()
(T1.f(3, [6]) ) |> IO.inspect()
(T1.f(3, [6, 7, 8, 6, 7, 8, 6, 7, 9]) ) |> IO.inspect()
(T1.f(3, [2, 2, 2, 3, 3, 3]) ) |> IO.inspect()

defmodule T2 do
  # Az am és bm zsákok metszete a cm zsák, azaz a cm kizárólag az am és bm közös elemeit
  # tartalmazza, mégpedig úgy, hogy cm minden elemének multiplicitása az adott elem
  # am-beli és bm-beli multiplicitása közül a kisebbik.
  # Az am és bm zsákok üresek is lehetnek. (11 pont)
  def metszet(am, bm) do
    for({k1, v1} <- am, do: for({k2, v2} <- bm, do: {{k1, v1}, {k2, v2}}))
    |> List.flatten()
    |> Enum.filter(fn {{k1, v1}, {k2, v2}} -> k1 == k2 end)
    |> Enum.map(fn {{k1, v1}, {k2, v2}} -> {k1, min(v1, v2)} end)
    |> Map.new()
  end
end

IO.puts("T2")
(T2.metszet(%{}, %{}) === %{}) |> IO.inspect()
(T2.metszet(%{}, %{111=>10}) === %{}) |> IO.inspect()
(T2.metszet(%{11=>10,33=>30}, %{22=>20,44=>40}) === %{}) |> IO.inspect()
(T2.metszet(%{11=>10,22=>2,33=>30}, %{11=>1,22=>20}) === %{11=>1,22=>2}) |> IO.inspect()

defmodule T3 do
  @spec lejto(xs :: [integer()], zs :: [z :: integer()]) :: {ls :: [integer()], rs :: [integer()]}
  # Az [z|xs] egészlista balról az első, lehető leghosszabb, folytonos,
  # szigorúan monoton csökkenő sorozata ls, maradéka rs
  def lejto([x | xs], [z | _] = zs) when z > x, do: lejto(xs, [x | zs])
  def lejto(xs, zs), do: {Enum.reverse(zs), xs}

  # Az rss az xs-ben előforduló lejtők listája
  # Lejtőnek nevezzük a legalább két elemű, egyik irányban sem kiterjeszthető,
  # folytonos, szigorúan monoton csökkenő sorozatot. (10 pont)
  def lejtok(xs) do
    lejtok(xs, [])
  end
  defp lejtok([], acc), do: Enum.reverse(acc)
  defp lejtok(xs, acc) do
    [x|t] = xs
    {lejto, maradek} = lejto(t, [x])
    acc = if length(lejto) > 1, do: [lejto|acc], else: acc
    lejtok(maradek, acc)
  end
end

IO.puts "T3"
(T3.lejtok([0, 0, 0, 0]) === []) |> IO.inspect()
(T3.lejtok([-1, -2, -3, -4]) === [[-1, -2, -3, -4]]) |> IO.inspect()
(T3.lejtok([]) === []) |> IO.inspect()
(T3.lejtok([5]) === []) |> IO.inspect()
(T3.lejtok([5, 4]) === [[5, 4]]) |> IO.inspect()
(T3.lejtok([4, 0, 6, 0, 9, 18]) === [[4, 0], [6, 0]]) |> IO.inspect()
(T3.lejtok([0, 0, 0, 0]) ) |> IO.inspect()
(T3.lejtok([-1, -2, -3, -4]) ) |> IO.inspect()
(T3.lejtok([]) ) |> IO.inspect()
(T3.lejtok([5]) ) |> IO.inspect()
(T3.lejtok([5, 4]) ) |> IO.inspect()
(T3.lejtok([4, 0, 6, 0, 9, 18]) ) |> IO.inspect()

defmodule T4 do
  @type bintree() :: :l | {bintree(), v :: any(), bintree()}
  @spec median(t :: bintree()) :: med :: float() | nil
  # a t fában lévő számok átlaga med (12 pont)
  def median(t) do
    numbers = nums(t) |> Enum.sort
    len = length(numbers)
    ix = div(len, 2)
    if len == 0 do
      nil
    else
     if rem(len, 2) == 0 do
        (Enum.at(numbers, ix) + Enum.at(numbers, ix - 1)) / 2
      else
        Enum.at(numbers, ix)
      end
    end
  end

  def nums(t) do
    nums(t, [])
  end
  defp nums(:l, acc) do
    acc
  end
  defp nums({left, val, right}, acc) do
    acc = if is_integer(val), do: [val|acc], else: acc
    acc = nums(left, acc)
    nums(right, acc)
  end
end

IO.puts "T4"
t0a = {:l, 8, :l}
t0b = {:l, :a, :l}
t1a = {{:l, 5, :l}, 6, {:l, 4, :l}}
t1b = {{:l, 5, :l}, :a, {:l, 4, :l}}
t1c = {{:l, :b, :l}, :a, {:l, :c, :l}}
t2a = {{{:l, :a, :l}, 8, {:l, 5, :l}}, 7, {:l, 6, :l}}
t2b = {{{:l, 9, :l}, :a, :l}, 3, {:l, 6, :l}}
t3a = {{{{{{{:l, 11, :l}, 7, {:l, 12, :l}}, 13, :l}, 9, :l}, 3, :l}, 5, :l}, 4, :l}
t3b = {{{{{{{:l, :x, :l}, 7, {:l, 12, :l}}, 13, :l}, 1, :l}, 5, :l}, 4, :l}, :a, :l}
(T4.median(t0a) == 8.0) |> IO.inspect()
(T4.median(t0b) == nil) |> IO.inspect()
(T4.median(t1a) == 5.0) |> IO.inspect()
(T4.median(t1b) == 4.5) |> IO.inspect()
(T4.median(t1c) == nil) |> IO.inspect()
(T4.median(t2a) == 6.5) |> IO.inspect()
(T4.median(t2b) == 6.0) |> IO.inspect()
(T4.median(t3a) == 8.0) |> IO.inspect()
(T4.median(t3b) == 6.0) |> IO.inspect()
(T4.median(t0a) ) |> IO.inspect()
(T4.median(t0b) ) |> IO.inspect()
(T4.median(t1a) ) |> IO.inspect()
(T4.median(t1b) ) |> IO.inspect()
(T4.median(t1c) ) |> IO.inspect()
(T4.median(t2a) ) |> IO.inspect()
(T4.median(t2b) ) |> IO.inspect()
(T4.median(t3a) ) |> IO.inspect()
(T4.median(t3b) ) |> IO.inspect()
