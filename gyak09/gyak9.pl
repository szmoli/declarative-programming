% 1.

szamtani_sorozat1(L, H1, D, N) :-
    L = [H1,H2|_],
    length(L, N),
    N >= 2,
    D is H2 - H1.

% 2.

szamtani_sorozat2([X0], X0, _D, 1).

szamtani_sorozat2([X0|Maradek], X0, D, N) :-
    N > 1,
    N1 is N - 1,
    X1 is X0 + D,
    szamtani_sorozat2(Maradek, X1, D, N1).

% 3.

szamtani_sorozat3(L, X0, D, N) :-
    nonvar(L),
    szamtani_sorozat1(L, X0, D, N).

szamtani_sorozat3(L, X0, D, N) :-
    integer(X0), integer(D), N >= 2,
    szamtani_sorozat2(L, X0, D, N).

% 4.

szamtani_sorozat4(L, D, N) :-
    length(L, N),
    nth1(Ix1, L, E1),
    integer(E1),
    (
        integer(D) -> 
            X0 is E1 - (Ix1 - 1) * D,
            szamtani_sorozat2(L, X0, D, N)
    ;
        nth1(Ix2, L, E2),
        integer(E2),
        Ix2 > Ix1,
        Div = Ix2 - Ix1,
        Diff = E2 - E1,
        D is Diff / Div,
        X0 is E1 - (Ix1 - 1) * D,
        szamtani_sorozat2(L, X0, D, N)
    ).

f5(L, X) :-
    nth1(Ix2, L, X),
    Ix1 is Ix2 - 1,
    Ix3 is Ix2 + 1,
    nth1(Ix1, L, P),
    nth1(Ix3, L, N),
    (
        P < X ->
            X > N
    ;
        P > X ->
            X < N
    ).

f6(L, X-N) :-
    nth1(Ix1, L, X),
    Ix2 is Ix1 + 1,
    nth1(Ix2, L, N),
    5 is N + X.