defmodule T1 do
  def f(i, xs) do
    # @spec f1(xs :: [any()]) :: rs :: [any()]
    # Az xs lista hárommal *nem* osztható indexű elemeiből álló lista zs, az
    # elemek eredeti sorrendjében. Indexelés 0-tól. Az xs lista üres is lehet. (3 pont)
    f1 = fn xs ->
      for {x, ix} <- Enum.with_index(xs), rem(ix, 3) != 0, do: x
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
      xs
      |> Enum.chunk_while(
        [],
        fn
          x, [] ->
            {:cont, [x]}

          x, [prev | tail] ->
            if prev > x do
              {:cont, Enum.reverse([prev | tail], [x])}
            else
              {:cont, [x | [prev | tail]]}
            end
        end,
        fn
          [] -> {:cont, []}
          acc -> {:cont, Enum.reverse(acc), []}
        end
      )
    end

    case i do
      1 -> f1.(xs)
      2 -> f2.(xs)
      3 -> f3.(xs)
    end
  end
end

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

defmodule T3 do
  @spec lejto(xs :: [integer()], zs :: [z :: integer()]) :: {ls :: [integer()], rs :: [integer()]}
  # Az [z|xs] egészlista balról az első, lehető leghosszabb, folytonos,
  # szigorúan monoton csökkenő sorozata ls, maradéka rs
  def lejto([x | xs], [z | _] = zs) when z > x, do: lejto(xs, [x | zs])
  def lejto(xs, zs), do: {Enum.reverse(zs), xs}

  # Az rss az xs-ben előforduló lejtők listája
  # Lejtőnek nevezzük a legalább két elemű, egyik irányban sem kiterjeszthető,
  # folytonos, szigorúan monoton csökkenő sorozatot. (10 pont)
  # def lejtok(xs) do
  #
  # end
end

defmodule T4 do
  @type bintree() :: :l | {bintree(), v :: any(), bintree()}
  @spec median(t :: bintree()) :: med :: float() | nil
  # a t fában lévő számok átlaga med (12 pont)
  def median(t) do
  end
end
