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

% Egy vonal elemei, amik felvehetik E-t.
felvehetik([], _, []).
felvehetik([H|T1], E, [H|T2]) :-
    felveheti(H, E),
    !,
    felvehetik(T1, E, T2).
felvehetik([_|T], E, Felvehetik) :-
    felvehetik(T, E, Felvehetik).

% Egy lista hány eleme lista.
lista_darab([], 0).
lista_darab([H|T], Darab) :-
    lista_darab(T, Darab1),
    (   
        is_list(H) -> Darab is Darab1 + 1
    ;   
        Darab = Darab1
    ).

% Mátrix sora.
sor(Ix, Mx, Sor) :-
    nth1(Ix, Mx, Sor).

% Mátrix oszlopa.
oszlop(Ix, Mx, Oszlop) :-
    maplist(nth1(Ix), Mx, Oszlop).

nullat_felveheto_tartomanyok_csere([], []).
nullat_felveheto_tartomanyok_csere([H|T1], [[0]|T2]) :-
    is_list(H),
    felveheti(H, 0),
    !,
    nullat_felveheto_tartomanyok_csere(T1, T2).
nullat_felveheto_tartomanyok_csere([H|T1], [H|T2]) :-
    nullat_felveheto_tartomanyok_csere(T1, T2).

cserel_vonal(sor(Ix, _E), MxBe, Vonal, MxKi) :-
    cserel_sor(MxBe, Ix, Vonal, MxKi).

cserel_vonal(oszl(Ix, _E), MxBe, Vonal, MxKi) :-
    cserel_oszlop(MxBe, Ix, Vonal, MxKi).

% MxKi egy mátrix ahol az adott Sor-t kicseréltük.
cserel_sor(MxBe, 1, Sor, [Sor|T]) :-  
    MxBe = [_|T].
cserel_sor([H|T], Ix, Sor, [H|R]) :-
    Ix > 1,
    Ix1 is Ix - 1,
    cserel_sor(T, Ix1, Sor, R).

% MxKi egy mátrix ahol az adott Oszlopo-t kicseréltük.
cserel_oszlop([], _, [], []).  % ha nincs több sor, kész
cserel_oszlop([Sor|T], Index, [Elem|VegsoOszlopT], [UjSor|UjMatrixT]) :-
    cserel_lista_elem(Sor, Index, Elem, UjSor),
    cserel_oszlop(T, Index, VegsoOszlopT, UjMatrixT).

% Kimeneti lista egy olyan lista amiben az Index-el adott helyen kicseréltünk egy elemet.
cserel_lista_elem([_|T], 1, Elem, [Elem|T]).
cserel_lista_elem([H|T], Ix, Elem, [H|R]) :-
    Ix > 1,
    Ix1 is Ix - 1,
    cserel_lista_elem(T, Ix1, Elem, R).

% :- pred kizarasos_szukites(feladvany_leiro::in, t_matrix::in, t_matrix::out, szukites::out).

csak_listak([], []).
csak_listak([H|T1], [H|T2]) :-
    is_list(H),
    !,
    csak_listak(T1, T2).
csak_listak([_|T], CsakListak) :-
    csak_listak(T, CsakListak).

vonal_keres(N, Z, Mx, E, Sz, Vonal, Felvehetik, Darab) :-
    between(1, N, Ix),
    sor(Ix, Mx, Sor),
    felvehetik(Sor, E, Felvehetik),
    length(Felvehetik, Darab),
    csak_listak(Felvehetik, CsakListak),
    (
        E = 0 -> 
        ( 
            Darab = Z,
            CsakListak \= [] -> Sz = sor(Ix, E)
        ; 
            Darab < Z -> Sz = nem(Ix, E)
        )
    ;
        E > 0 -> 
        ( 
            Darab = 1,
            CsakListak \= [] -> Sz = sor(Ix, E)
        ; 
            Darab < 1 -> Sz = nem(Ix, E)
        )
    ),
    !,   
    Vonal = Sor.

vonal_keres(N, Z, Mx, E, Sz, Vonal, Felvehetik, Darab) :-
    between(1, N, Ix),
    oszlop(Ix, Mx, Oszlop),
    felvehetik(Oszlop, E, Felvehetik),
    length(Felvehetik, Darab),
    csak_listak(Felvehetik, CsakListak),
    (
        E = 0 -> 
        ( 
            Darab = Z,
            CsakListak \= [] -> Sz = oszl(Ix, E)
        ; 
            Darab < Z -> Sz = nem(Ix, E)
        )
    ;
        E > 0 -> 
        ( 
            Darab = 1,
            CsakListak \= [] -> Sz = oszl(Ix, E)
        ; 
            Darab < 1 -> Sz = nem(Ix, E)
        )
    ),
    !,   
    Vonal = Oszlop.

%szukit(SzBe, Vonal, Felvehetik, Darab, Z, MxBe, MxKi, SzKi) :-


kizarasos_szukites(szt(N, M, _), MxBe, MxKi, Sz) :-
    Z is N - M,
    between(0, M, E),
    vonal_keres(N, Z, MxBe, E, SzVonal, Vonal, Felvehetik, Darab),
    szukit(SzVonal, Vonal, Felvehetik, Darab, Z, MxBe, MxKi, Sz).
        