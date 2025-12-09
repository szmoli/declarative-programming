% 1.

atom_prefix(Atom, Prefix, N) :-
    atom_codes(Atom, Codes),
    append(PrefixCodes, _Rest, Codes),
    length(PrefixCodes, N),
    atom_codes(Prefix, PrefixCodes).

% 2.

reszatom(A, A) :-
    atom(A).

reszatom(K, A) :-
    compound(K),
    K =.. KL,
    KL = [_|Args],
    member(Arg, Args),
    reszatom(Arg, A).

% 3.

osszege(K, S) :-
    (
        integer(K) -> S = K
    ;
        compound(K) ->
            K =.. KL,
            KL = [_|Args],  
            osszege_2(Args, S)
    ;
        S = 0
    ).

osszege_2([], 0).

osszege_2([H|T], S) :-
    osszege(H, HOssz),
    osszege_2(T, TOssz),
    S is HOssz + TOssz.

% 4.

p(1).
p(2).
p(X) :- X > 1.

m(2, 0).
m(1, 2).
m(1, 3).
m(2, 1).
m(_, 4).

q(X) :- m(_, X), p(X).

% a: fail -> sikerül: X = 1
% b: sikerül: X = bc
% c: fail -> sikerül: X = 2
% d: sikerül: X = 2; 3; 4
% e: hiba -> sikerül: 2; 2; 3; 1; 4

% 5.

helyettesitese(K, _HL, K) :-
    number(K), !.

helyettesitese(K, HL, E) :-
    atom(K),
    member(K-E, HL), !.

helyettesitese(K, HL, E) :-
    atom(K),
    \+ member(K-_, HL),
    E = 0.

% 6.

% ?- K = -x, K =.. [Pred|Args], K =.. D, member(Arg, Args), helyettesitese(Arg, [x-5], H), E =.. [Pred, H].

erteke(Kif, Hely, Ert) :-
    (
        compound(Kif) ->
            Kif =.. [Pred|Args],
            (
                Args = [Kif1, Kif2] ->
                    erteke(Kif1, Hely, H1),
                    erteke(Kif2, Hely, H2),
                    HKif =.. [Pred, H1, H2],
                    Ert is HKif
            ;
                Args = [Kif1] ->
                    erteke(Kif1, Hely, H1),
                    HKif =.. [Pred, H1],
                    Ert is HKif
            )
    ;
        helyettesitese(Kif, Hely, H),
        Ert is H
    ).

% 7.

kisbetu(K) :-
    K >= 0'a, K =< 0'z.

kezdo_szava(L, Kezdet, Maradek) :- 
    k_sz_rekurzio(L, Kezdet, Maradek),
    length(Kezdet, Len), Len >= 2.

k_sz_rekurzio([X|Xs], [], [X|Xs]) :-
    \+ kisbetu(X).

k_sz_rekurzio([], [], []).

k_sz_rekurzio([X|Xs], [X|Ks], Ms) :-
    kisbetu(X),
    k_sz_rekurzio(Xs, Ks, Ms).

szava(Atom, Szo, Index) :-
    atom_codes(Atom, Cs),
    szava_rekurzio(Cs, Szo, 1, Index).

szava_rekurzio(L, Szo, Index0, Index) :-
    kezdo_szava(L, SzoL, Maradek), !,
    length(SzoL, Len),
    Index1 is Index0 + Len,
    (
        atom_codes(Szo, SzoL),
        Index = Index0
    ;
        szava_rekurzio(Maradek, Szo, Index1, Index)
    ).

szava_rekurzio(L, Szo, Index0, Index) :-
    Index1 is Index0 + 1,
    L = [_X|Xs],
    szava_rekurzio(Xs, Szo, Index1, Index).