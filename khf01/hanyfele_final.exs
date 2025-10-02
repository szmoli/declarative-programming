defmodule Khf1 do
  @moduledoc """
  Hányféle módon állítható elő a célérték
  @author "Szmoleniczki Ákos <szmoleniczki.akos@edu.bme.hu>"
  @date   "2025-09-25"

  A memoization technikához az Deepseek segítségét kértem az alábbi prompttal, majd ez alapján dolgoztam ki a saját megoldásom.
  Prompt:
    Mutass nekem egy memoization példát Elixir nyelven
  Válasz:
    defmodule SimpleMemoFibonacci do
      def fib(n) do
        {result, _} = fib_memo(n, %{})
        result
      end

      defp fib_memo(n, memo) do
        cond do
          n == 0 -> {0, memo}
          n == 1 -> {1, memo}
          Map.has_key?(memo, n) -> {memo[n], memo}
          true ->
            {fib1, memo1} = fib_memo(n - 1, memo)
            {fib2, memo2} = fib_memo(n - 2, memo1)
            result = fib1 + fib2
            {result, Map.put(memo2, n, result)}
        end
      end
    end
  """
  # az összeg előállítására felhasználható érték (0 < ertek)
  @type ertek() :: integer()
  # az értékből rendelkezésre álló maximális darabszám (0 ≤ darabszám)
  @type darab() :: integer()
  @type ertekek() :: %{ertek() => darab()}
  @type celertek() :: integer()
  @spec hanyfele(ertekek :: ertekek(), celertek :: integer()) :: ennyifele :: integer()
  # ennyifele a celertek összes különböző előállításainak száma ertekek felhasználásával
  def hanyfele(ertekek, celertek) do
    # mohó algoritmus: nagy értékekkel kezd, ezzel biztosítva, hogy nem számoljuk ugyanazt a kombinációt más sorrendekben
    ertek_lista = Enum.sort(ertekek, :desc)
    {eredmeny, _vegso_memo} = hanyfele(ertek_lista, celertek, 0, %{})
    eredmeny
  end

  @type idx() :: integer()
  @type reszeredmeny() :: integer()
  # memoization: már kiszámolt értékeket eltároljuk memo-ban és újraszámolás helyett innen olvassuk
  @type memo() :: %{{celertek(), idx()} => reszeredmeny()}
  @spec hanyfele(ertekek :: ertekek(), celertek :: celertek(), idx :: idx(), memo :: memo()) :: integer()
  # alapeset: ertekek kombinálásával kijött a celertek
  defp hanyfele(_ertekek, 0, _idx, memo), do: {1, memo}

  # alapeset: ertekek kombinálásával túllőttönk a célon, nem lehet kitenni belőlük celerteket
  defp hanyfele(_ertekek, celertek, _idx, memo) when celertek < 0, do: {0, memo}
  # alapeset: védekezés túlindexelés ellen
  defp hanyfele(ertekek, _celertek, idx, memo) when idx > length(ertekek) - 1, do: {0, memo}
  # rekurzív hívás kiszámolja a részeredményeket és az ezáltal frissített memo-t
  defp hanyfele(ertekek, celertek, idx, memo) do
    memo_kulcs = {celertek, idx}
    memo_eredmeny = Map.get(memo, memo_kulcs)

    if memo_eredmeny do
      {memo_eredmeny, memo}
    else
      {ertek, limit} = Enum.at(ertekek, idx)

      max_hasznalatok_szama =
        if limit == 0, do: div(celertek, ertek), else: min(limit, div(celertek, ertek))

      {eredmeny, uj_memo} =
        Enum.reduce(0..max_hasznalatok_szama, {0, memo}, fn hasznalatok_szama, {kombinaciok_szama, aktualis_memo} ->
          uj_celertek = celertek - hasznalatok_szama * ertek
          {reszeredmeny, frissitett_memo} = hanyfele(ertekek, uj_celertek, idx + 1, aktualis_memo)
          {kombinaciok_szama + reszeredmeny, frissitett_memo}
        end)

      vegso_memo = Map.put(uj_memo, memo_kulcs, eredmeny)
      {eredmeny, vegso_memo}
    end
  end
end
