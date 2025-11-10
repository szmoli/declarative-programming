% Szmoleniczki Ákos (szmoleniczki.akos@edu.bme.hu)
% 2025-11-10
%  Minimális segítségkérések a ChatGPT-től a feladat megoldása során:
% - Elmagyarázta a Prolog \+ (negáció) operátor működését és alternatíváit.
% - Segített megtalálni, miért generált több megoldást az ismert_szukites/3, mint amennyi várt volt.
% - Rámutatott, hogy a rekurzió miatt a predikátum többször visszatérhetett ugyanazzal az eredménnyel.
% - Segített megoldani, hogy az ismert_szukites/3 bukjon el, ha nincsenek ismert értékek a mátrixban.
% - Segített pontosítani a vágások (!) helyes használatát.

:- use_module(library(lists)).
:- use_module(library(clpfd)).

% :- type feladvany_leiro ---> szt(meret, ciklus, list(adott_elem)).
% :- type meret             == integer.
% :- type ciklus            == integer.
% :- type adott_elem      ---> i(sorszam, oszlopszam, ertek).
% :- type sorszam           == integer.
% :- type oszlopszam        == integer.
% :- type ertek             == integer.

% :- type t_matrix          == list(t_sor).
% :- type t_sor             == list(t_ertek).
% :- type t_ertek           == list(integer) \/ integer.  % egészek listája vagy egész

% :- pred szamok(integer::in, integer::in, t_ertek::out).
szamok(Tol, Tol, [Tol]) :- !. 

szamok(Tol, Ig, [Tol|Maradek]) :-
    Tol < Ig,
    Tol1 is Tol + 1,
    szamok(Tol1, Ig, Maradek).

szamok(Tol, Ig, [Tol|Maradek]) :-
    Tol > Ig,
    Tol1 is Tol - 1,
    szamok(Tol1, Ig, Maradek).

% :- pred t_ertek(sorszam::in, oszlopszam::in, feladvany_leiro::in, t_ertek::out).
t_ertek(Sorszam, Oszlopszam, szt(_N, _M, Adottak), [Adott]) :-
    member(i(Sorszam, Oszlopszam, Adott), Adottak), !.

t_ertek(_Sorszam, _Oszlopszam, szt(N, M, _Adottak), TErtek) :-
    N > M,
    szamok(0, M, TErtek).

t_ertek(_Sorszam, _Oszlopszam, szt(N, M, _Adottak), TErtek) :-
    N =:= M,
    szamok(1, M, TErtek).

% pred t_sor(sorszam::in, feladvany_leiro::in, t_sor::out).
t_sor(Sorszam, szt(N, M, Adottak), TSor) :- 
    szamok(1, N, Oszlopszamok),
    t_sor(Sorszam, Oszlopszamok, szt(N, M, Adottak), TSor).

t_sor(Sorszam, [Oszlopszam], szt(N, M, Adottak), [TErtek]) :-
    t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek).

t_sor(Sorszam, [Oszlopszam|Oszlopszamok], szt(N, M, Adottak), [TErtek|Maradek]) :-
    t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek),
    t_sor(Sorszam, Oszlopszamok, szt(N, M, Adottak), Maradek).

% pred t_matrix(feladvany_leiro::in, t_matrix::out).
t_matrix(szt(N, M, Adottak), Mx) :-
    szamok(1, N, Szamok),
    t_matrix(Szamok, szt(N, M, Adottak), Mx).

t_matrix([Sorszam], szt(N, M, Adottak), [TSor]) :-
    t_sor(Sorszam, szt(N, M, Adottak), TSor).

t_matrix([Sorszam|Sorszamok], szt(N, M, Adottak), [TSor|Maradek]) :-
    t_sor(Sorszam, szt(N, M, Adottak), TSor),
    t_matrix(Sorszamok, szt(N, M, Adottak), Maradek).

% :- pred kezdotabla(feladvany_leiro::in, t_matrix::out).
kezdotabla(szt(N, M, Adottak), Mx) :-
    t_matrix(szt(N, M, Adottak), Mx).

% pred sor(sorszam::in, t_matrix::in, t_sor::out).
sor(Sorszam, Mx, TSor) :-
    nth1(Sorszam, Mx, TSor).

% pred oszlop(oszlopszam::in, t_matrix::in, t_sor::out).
oszlop(Oszlopszam, Mx, TOszlop) :-
    maplist(nth1(Oszlopszam), Mx, TOszlop).

% pred adott(t_sor::in, ertek::out).
adott([E], E) :- !.

t_sor_szukites(E, TSor, SzTSor) :-
    maplist(t_ertek_szukites(E), TSor, SzTSor).

% t_ertek_szukites(_, E, E) :- 
%     integer(E), !.
% 
% t_ertek_szukites(_, [E], E) :- !.
% 
% t_ertek_szukites(E, TErtek, SzTErtek) :-
%     select(E, TErtek, SzTErtek).
% 
% t_matrix_szukites(E, Mx, SzMx) :-
%     maplist(t_sor_szukites(E), Mx, SzMx).

elhagy(_, E, E) :-
    integer(E), !.

elhagy(E, [E], E) :-
    integer(E), !.

elhagy(E, TErtek, SzTErtek) :-
    select(E, TErtek, SzTErtek).

ertek(Sorszam, Oszlopszam, Mx, E) :- 
    nth1(Sorszam, Mx, Sor), 
    nth1(Oszlopszam, Sor, E).

szukitett_ertek(Sorszam, Oszlopszam, MxBe, E, MxKi) :-
    nth1(Sorszam, MxBe, RegiSor, MaradekSorok),
    nth1(Oszlopszam, RegiSor, _RegiE, MaradekEk),
    nth1(Oszlopszam, UjSor, E, MaradekEk),
    nth1(Sorszam, MxKi, UjSor, MaradekSorok).

darab(_, [], 0).
darab(E, [E|T], Darab) :-
    darab(E, T, Darab1),
    Darab is Darab1 + 1.
darab(E, [_|T], Darab) :-
    darab(E, T, Darab).

szukites(E, Sorszam, Oszlopszam, _N, _M, MxBe, []) :-
    E > 0,
    sor(Sorszam, MxBe, TSor),
    sorbol_elhagy(E, Oszlopszam, TSor, SzTSor), 
    member([], SzTSor), !.
szukites(E, Sorszam, Oszlopszam, _N, _M, MxBe, []) :-
    E > 0,
    sor(Sorszam, MxBe, TSor),
    sorbol_elhagy(E, Oszlopszam, TSor, SzTSor), 
    szukitett_sor(Sorszam, MxBe, SzTSor, MxSorUtan),
    oszlop(Oszlopszam, MxSorUtan, TOszlop),
    oszlopbol_elhagy(E, Sorszam, TOszlop, SzTOszlop),
    member([], SzTOszlop), !.
szukites(E, Sorszam, Oszlopszam, _N, _M, MxBe, MxKi) :-
    E > 0,
    sor(Sorszam, MxBe, TSor),
    sorbol_elhagy(E, Oszlopszam, TSor, SzTSor), 
    szukitett_sor(Sorszam, MxBe, SzTSor, MxSorUtan),
    oszlop(Oszlopszam, MxSorUtan, TOszlop),
    oszlopbol_elhagy(E, Sorszam, TOszlop, SzTOszlop),
    szukitett_oszlop(Oszlopszam, MxSorUtan, SzTOszlop, MxOszlopUtan), 
    szukitett_ertek(Sorszam, Oszlopszam, MxOszlopUtan, E, MxKi).

szukites(E, Sorszam, Oszlopszam, N, M, MxBe, []) :-
    E = 0,
    sor(Sorszam, MxBe, TSor),
    nullak_kibontva(TSor, SzTSor),
    szukitett_sor(Sorszam, MxBe, SzTSor, MxOszlopUtan),
    oszlop(Oszlopszam, MxOszlopUtan, TOszlop),
    nullak_kibontva(TOszlop, SzTOszlop),
    szukitett_oszlop(Oszlopszam, MxOszlopUtan, SzTOszlop, MxNullakKibontva),
    ElvartZ is N - M,
    sor(Sorszam, MxNullakKibontva, TSorNullakKibontva),
    darab(0, TSorNullakKibontva, SorZ),
    SorZ > ElvartZ, !.

szukites(E, Sorszam, Oszlopszam, N, M, MxBe, []) :-
    E = 0,
    sor(Sorszam, MxBe, TSor),
    nullak_kibontva(TSor, SzTSor),
    szukitett_sor(Sorszam, MxBe, SzTSor, MxOszlopUtan),
    oszlop(Oszlopszam, MxOszlopUtan, TOszlop),
    nullak_kibontva(TOszlop, SzTOszlop),
    szukitett_oszlop(Oszlopszam, MxOszlopUtan, SzTOszlop, MxNullakKibontva),
    ElvartZ is N - M,
    sor(Sorszam, MxNullakKibontva, TSorNullakKibontva),
    darab(0, TSorNullakKibontva, SorZ),
    SorZ = ElvartZ,
    sorbol_elhagy(E, Oszlopszam, TSorNullakKibontva, TSorNullakElhagyva),
    szukitett_sor(Sorszam, MxNullakKibontva, TSorNullakElhagyva, MxSorbolNullakElhagyva),
    oszlop(Oszlopszam, MxSorbolNullakElhagyva, TOszlopNullakKibontva),
    darab(0, TOszlopNullakKibontva, OszlopZ),
    OszlopZ > ElvartZ, !.

szukites(E, Sorszam, Oszlopszam, N, M, MxBe, MxKi) :-
    E = 0,
    sor(Sorszam, MxBe, TSor),
    nullak_kibontva(TSor, SzTSor),
    szukitett_sor(Sorszam, MxBe, SzTSor, MxOszlopUtan),
    oszlop(Oszlopszam, MxOszlopUtan, TOszlop),
    nullak_kibontva(TOszlop, SzTOszlop),
    szukitett_oszlop(Oszlopszam, MxOszlopUtan, SzTOszlop, MxNullakKibontva),
    ElvartZ is N - M,
    sor(Sorszam, MxNullakKibontva, TSorNullakKibontva),
    darab(0, TSorNullakKibontva, SorZ),
    SorZ = ElvartZ,
    sorbol_elhagy(E, Oszlopszam, TSorNullakKibontva, TSorNullakElhagyva),
    szukitett_sor(Sorszam, MxNullakKibontva, TSorNullakElhagyva, MxSorbolNullakElhagyva),
    oszlop(Oszlopszam, MxSorbolNullakElhagyva, TOszlopNullakKibontva),
    darab(0, TOszlopNullakKibontva, OszlopZ),
    OszlopZ = ElvartZ,
    oszlopbol_elhagy(E, Oszlopszam, TOszlopNullakKibontva, TOszlopNullakElhagyva),
    szukitett_oszlop(Oszlopszam, MxSorbolNullakElhagyva, TOszlopNullakElhagyva, MxKi).

sorbol_elhagy(_, _, [], []).
sorbol_elhagy(E, 1, [H|T1], [H|T2]) :-  
    sorbol_elhagy(E, 0, T1, T2), !.
sorbol_elhagy(E, N, [H1|T1], [H2|T2]) :-
    select(E, H1, H2), !,
    N1 is N - 1,
    sorbol_elhagy(E, N1, T1, T2).
sorbol_elhagy(E, N, [H|T1], [H|T2]) :-
    N1 is N - 1,
    sorbol_elhagy(E, N1, T1, T2).

oszlopbol_elhagy(E, N, TOszlopBe, TOszlopKi) :-
    sorbol_elhagy(E, N, TOszlopBe, TOszlopKi).

nullak_kibontva([], []).
nullak_kibontva([H|T1], [0|T2]) :-
    [0] = H,
    nullak_kibontva(T1, T2), !.
nullak_kibontva([H|T1], [H|T2]) :-
    nullak_kibontva(T1, T2).

szukitett_sor(Sorszam, MxBe, SzTSor, MxKi) :-
    nth1(Sorszam, MxBe, _, Maradek),
    nth1(Sorszam, MxKi, SzTSor, Maradek).

szukitett_oszlop(Oszlopszam, MxBe, SzTOszlop, MxKi) :-
    transpose(MxBe, MxBeT),
    nth1(Oszlopszam, MxBeT, _, Maradek),
    nth1(Oszlopszam, MxKiT, SzTOszlop, Maradek),
    transpose(MxKiT, MxKi).

ismert_szukites(szt(_N, _M, _), [], []) :- !.

ismert_szukites(szt(_N, _M, _), MxBe, MxBe) :-
    \+ (member(TSor, MxBe), member(TErtek, TSor), adott(TErtek, _E)), !.

% :- pred ismert_szukites(feladvany_leiro::in, t_matrix::in, t_matrix::out).
ismert_szukites(szt(N, M, _), MxBe, MxKi) :-
    member(TSor, MxBe),
    member(TErtek, TSor),
    adott(TErtek, Ertek),
    nth1(Sorszam, MxBe, TSor),
    nth1(Oszlopszam, TSor, TErtek),
    szukites(Ertek, Sorszam, Oszlopszam, N, M, MxBe, MxSzukitett),
    ismert_szukites(szt(N, M, _), MxSzukitett, MxKi), !.
