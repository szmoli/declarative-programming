% Készítette: Szmoleniczki Ákos
% 2025-11-16

:- use_module(library(lists)).

% :- type feladvany_leiro ---> szt(meret,ciklus,list(adott_elem)).
% :- type meret             == integer.
% :- type ciklus            == integer.
% :- type adott_elem      ---> i(sorszam,oszlopszam,ertek).
% :- type sorszam           == integer.
% :- type oszlopszam        == integer.
% :- type ertek             == integer.

% :- type t_matrix          == list(t_sor).
% :- type t_sor             == list(t_ertek).
% :- type t_ertek           == list(integer) \/ integer.  % egészek listája vagy egész

% :- type szukites        ---> sor(sorszam,ertek) ; oszl(oszlopszam,ertek) ; nem.

% Tartomány felveheti-e E-t.
felveheti(E, E) :-
    integer(E).
felveheti(Tartomany, E) :-
    is_list(Tartomany),
    member(E, Tartomany).

felvehetik(Vonal, E, Felvehetik) :-
    felvehetik(Vonal, E, 1, Felvehetik).

% Egy vonal elemei, amik felvehetik E-t.
felvehetik([], _, _, []).
felvehetik([H|T1], E, Ix, [felv(Ix, H)|T2]) :-
    felveheti(H, E),
    !,
    Ix1 is Ix + 1,
    felvehetik(T1, E, Ix1, T2).
felvehetik([_|T], E, Ix, Felvehetik) :-
    Ix1 is Ix + 1,
    felvehetik(T, E, Ix1, Felvehetik).

% Mátrix Ix-edik sora.
sor(Ix, Mx, Sor) :-
    nth1(Ix, Mx, Sor).

% Mátrix Ix-edik oszlopa.
oszlop(Ix, Mx, Oszlop) :-
    maplist(nth1(Ix), Mx, Oszlop).

% Egy vonalban lecseréli az összes 0-t felvehető tartományt [0]-ra.
nullat_felveheto_tartomanyok_csere([], []).
nullat_felveheto_tartomanyok_csere([H|T1], [[0]|T2]) :-
    is_list(H),
    felveheti(H, 0),
    !,
    nullat_felveheto_tartomanyok_csere(T1, T2).
nullat_felveheto_tartomanyok_csere([H|T1], [H|T2]) :-
    nullat_felveheto_tartomanyok_csere(T1, T2).

% Egy mátrix Ix-edik sorát cseréli le.
cserel_sor(MxBe, 1, Sor, [Sor|T]) :-  
    MxBe = [_|T].
cserel_sor([H|T], Ix, Sor, [H|R]) :-
    Ix > 1,
    Ix1 is Ix - 1,
    cserel_sor(T, Ix1, Sor, R).

% Egy mátrix Ix-edik oszlopát cseréli le.
cserel_oszlop([], _, [], []).  
cserel_oszlop([Sor|T], Ix, [Elem|VegsoOszlopT], [UjSor|UjMatrixT]) :-
    cserel_lista_elem(Sor, Ix, Elem, UjSor),
    cserel_oszlop(T, Ix, VegsoOszlopT, UjMatrixT).

% Egy lista Ix-edik elemét cseréli Elem-re.
cserel_lista_elem([_|T], 1, Elem, [Elem|T]).
cserel_lista_elem([H|T], Ix, Elem, [H|R]) :-
    Ix > 1,
    Ix1 is Ix - 1,
    cserel_lista_elem(T, Ix1, Elem, R).

% E-t felvehető tartományok közül kiszűri azokat, amik valóban tartományok és nem egész számok.
csak_tartomanyok([], []).
csak_tartomanyok([H|T1], [H|T2]) :-
    H = felv(_Ix, TE),
    is_list(TE),
    !,
    csak_tartomanyok(T1, T2).
csak_tartomanyok([_|T], CsakTartomanyok) :-
    csak_tartomanyok(T, CsakTartomanyok).

% Megkeresi az első vonalat a mátrixban. Először a sorokat nézi növekvő sorrendben, ha nem talál jót közülük, akkor az oszlopokkal folytatja. Ha egyetlen megfelelő vonal sincs, akkor meghiúsul.
vonal_keres(N, Z, Mx, E, Sz, Vonal, Felvehetik) :-
    between(1, N, Ix),
    sor(Ix, Mx, Sor),
    felvehetik(Sor, E, Felvehetik),
    length(Felvehetik, Darab),
    csak_tartomanyok(Felvehetik, CsakTartomanyok),
    (
        E = 0 -> 
        ( 
            Darab = Z,
            CsakTartomanyok \= [] -> Sz = sor(Ix, E)
        ; 
            Darab < Z -> Sz = nem(Ix, E)
        )
    ;
        E > 0 -> 
        ( 
            Darab = 1,
            CsakTartomanyok \= [] -> Sz = sor(Ix, E)
        ; 
            Darab < 1 -> Sz = nem(Ix, E)
        )
    ),
    !,   
    Vonal = Sor.

vonal_keres(N, Z, Mx, E, Sz, Vonal, Felvehetik) :-
    between(1, N, Ix),
    oszlop(Ix, Mx, Oszlop),
    felvehetik(Oszlop, E, Felvehetik),
    length(Felvehetik, Darab),
    csak_tartomanyok(Felvehetik, CsakTartomanyok),
    (
        E = 0 -> 
        ( 
            Darab = Z,
            CsakTartomanyok \= [] -> Sz = oszl(Ix, E)
        ; 
            Darab < Z -> Sz = nem(Ix, E)
        )
    ;
        E > 0 -> 
        ( 
            Darab = 1,
            CsakTartomanyok \= [] -> Sz = oszl(Ix, E)
        ; 
            Darab < 1 -> Sz = nem(Ix, E)
        )
    ),
    !,   
    Vonal = Oszlop.

% Szűkíti a mátrixot.
szukit(_Felvehetik, nem(_Ix, _E), _Vonal, _MxBe, [], nem).

% Mátrix szűkítésnek különböző esetei.
szukit(_Felvehetik, sor(Ix, 0), Vonal, MxBe, MxKi, sor(Ix, 0)) :-
    szukit_nullas(Vonal, SzukitettVonal),
    cserel_sor(MxBe, Ix, SzukitettVonal, MxKi).

szukit(Felvehetik, sor(Ix, E), Vonal, MxBe, MxKi, sor(Ix, E)) :-
    E > 0,
    szukit_pozitiv(Felvehetik, E, Vonal, SzukitettVonal),
    cserel_sor(MxBe, Ix, SzukitettVonal, MxKi).

szukit(_Felvehetik, oszl(Ix, 0), Vonal, MxBe, MxKi, oszl(Ix, 0)) :-
    szukit_nullas(Vonal, SzukitettVonal),
    cserel_oszlop(MxBe, Ix, SzukitettVonal, MxKi).

szukit(Felvehetik, oszl(Ix, E), Vonal, MxBe, MxKi, oszl(Ix, E)) :-
    E > 0,
    szukit_pozitiv(Felvehetik, E, Vonal, SzukitettVonal),
    cserel_oszlop(MxBe, Ix, SzukitettVonal, MxKi).

% Szűkítés E = 0 esetén. A Vonalban az összes nullát felvehető tartományt kicseréli [0]-ra.
szukit_nullas(VonalBe, VonalKi) :-
    nullat_felveheto_tartomanyok_csere(VonalBe, VonalKi).

% Szűkítés E > 0 esetén. A Vonalban [E]-re cseréli azt az egy tartományt ami felveheti E-t.
szukit_pozitiv(Felvehetik, E, VonalBe, VonalKi) :-
    Felvehetik = [Felveheti],
    Felveheti = felv(Ix, _TErtek),
    cserel_lista_elem(VonalBe, Ix, [E], VonalKi).

% :- pred kizarasos_szukites(feladvany_leiro::in, t_matrix::in, t_matrix::out, szukites::out).
kizarasos_szukites(szt(N, M, _), MxBe, MxKi, Sz) :-
    Z is N - M,
    between(0, M, E),
    vonal_keres(N, Z, MxBe, E, VonalSz, Vonal, Felvehetik),
    szukit(Felvehetik, VonalSz, Vonal, MxBe, MxKi, Sz).
        