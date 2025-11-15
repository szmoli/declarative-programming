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
    
% Feladatban megadott szűkítések
%szukites(0, ElvartZ, SorIx, OszlopIx, Vonal, Tipus, MxBe, MxKi, Sz) :-
%    szukites_nullas(ElvartZ, SorIx, OszlopIx, Vonal, Tipus, MxBe, MxKi, Sz),
%    !.
%szukites(E, _ElvartZ, SorIx, OszlopIx, Vonal, Tipus, MxBe, MxKi, Sz) :-
%    E > 0,
%    szukites_pozitiv(E, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi), 
%    !.   

szukites_pozitiv(E, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi) :-
    elhagy_kiveve(E, OszlopIx, Sor, ElhagyottSor),
    ( 
        member([], ElhagyottSor) -> MxKi = [] 
    ;
        elhagy_kiveve(E, SorIx, Oszlop, ElhagyottOszlop),
        ( 
            member([], ElhagyottOszlop) -> MxKi = [] 
        ;
            cserel_lista_elem(ElhagyottOszlop, SorIx, E, CsereltOszlop),
            cserel_sor(MxBe, SorIx, ElhagyottSor, MxSorCserelt),
            cserel_oszlop(MxSorCserelt, OszlopIx, CsereltOszlop, MxKi)
        )
    ).

szukites_nullas(ElvartZ, SorIx, OszlopIx, Vonal, Tipus, MxBe, MxKi, Sz) :-
    felvehetik(Vonal, 0, Felvehetik),
    length(Felvehetik, FelvehetiDb),
    ( 
        FelvehetiDb < ElvartZ -> 
            MxKi = [],
            Sz = nem
    ;
        FelvehetiDb =:= ElvartZ -> 
            nullat_felveheto_tartomanyok_csere(Vonal, CsereltVonal),
            (
                Tipus = oszlop ->
                    cserel_oszlop(MxBe, OszlopIx, CsereltVonal, MxKi),
                    Sz = oszl(OszlopIx, 0)
            ;
                Tipus = sor ->
                    cserel_sor(MxBe, SorIx, CsereltVonal, MxKi),
                    Sz = sor(SorIx, 0)
            )
    ).

nullat_felveheto_tartomanyok_csere([], []).
nullat_felveheto_tartomanyok_csere([H|T1], [[0]|T2]) :-
    is_list(H),
    felveheti(H, 0),
    !,
    nullat_felveheto_tartomanyok_csere(T1, T2).
nullat_felveheto_tartomanyok_csere([H|T1], [H|T2]) :-
    nullat_felveheto_tartomanyok_csere(T1, T2).

% MxKi egy mátrix ahol az adott Sor-t kicseréltük.
cserel_sor(Matrix, 1, Sor, [Sor|T]) :-  
    Matrix = [_|T].
cserel_sor([H|T], Index, Sor, [H|R]) :-
    Index > 1,
    NewIndex is Index - 1,
    cserel_sor(T, NewIndex, Sor, R).

% MxKi egy mátrix ahol az adott Oszlopo-t kicseréltük.
cserel_oszlop([], _, [], []).  % ha nincs több sor, kész
cserel_oszlop([Sor|T], Index, [Elem|VegsoOszlopT], [UjSor|UjMatrixT]) :-
    cserel_lista_elem(Sor, Index, Elem, UjSor),
    cserel_oszlop(T, Index, VegsoOszlopT, UjMatrixT).

% Kimeneti lista egy olyan lista amiben az Index-el adott helyen kicseréltünk egy elemet.
cserel_lista_elem([_|T], 1, Elem, [Elem|T]).
cserel_lista_elem([H|T], Index, Elem, [H|R]) :-
    Index > 1,
    NewIndex is Index - 1,
    cserel_lista_elem(T, NewIndex, Elem, R).

% :- pred kizarasos_szukites(feladvany_leiro::in, t_matrix::in, t_matrix::out, szukites::out).

csak_listak([], []).
csak_listak([H|T1], [H|T2]) :-
    is_list(H),
    !,
    csak_listak(T1, T2).
csak_listak([_|T], CsakListak) :-
    csak_listak(T, CsakListak).

vonal_keres(N, Z, Mx, E, Sz, Vonal) :-
    between(1, N, Ix),
    sor(Ix, Mx, Sor),
    felvehetik(Sor, E, SorFelvehetik),
    length(SorFelvehetik, Darab),
    Darab > 0,
    csak_listak(SorFelvehetik, CsakListak),
    CsakListak \= [],
    (
        E = 0 -> Darab =< Z
    ;
        E > 0 -> Darab =< 1
    ),
    !,   
    Sz = sor(Ix, E),
    Vonal = Sor.

vonal_keres(N, Z, Mx, E, Sz, Vonal) :-
    between(1, N, Ix),
    oszlop(Ix, Mx, Oszlop),
    felvehetik(Oszlop, E, OszlopFelvehetik),
    length(OszlopFelvehetik, Darab),
    Darab > 0,
    csak_listak(OszlopFelvehetik, CsakListak),
    CsakListak \= [],
    (
        E = 0 -> Darab =< Z
    ;
        E > 0 -> Darab =< 1
    ),
    !,   
    Sz = oszl(Ix, E),
    Vonal = Oszlop.

kizarasos_szukites(szt(N, M, _), Mx0, MxKi, Sz) :-
    Z is N - M,
    between(0, M, E),
    vonal_keres(N, Z, Mx0, E, Sz, Vonal),
    MxKi = Mx0.   
        
    %Z is N - M,
    %between(0, M, E), 
    %between(1, N, Ix), 
    %sor(Ix, Mx0, Sor), 
    %felvehetik(Sor, E, SorFelvehetik), 
    %length(SorFelvehetik, SorFelvehetikDarab), 
    %SorFelvehetikDarab > 0, 
    %csak_listak(SorFelvehetik, SorCsakListak), 
    %SorCsakListak \= [], 
    %(
    %    E = 0 -> SorFelvehetikDarab =< Z 
    %; 
    %    E > 0 -> SorFelvehetikDarab =< 1
    %).
   