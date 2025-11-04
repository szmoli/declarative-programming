head([H|_], H).

tail([_|T], T).

last([H], H).
last([_|T], L) :-
    last(T, L).

empty([]).

member([H|_], H).
member([_|T], M) :-
    member(T, M).

len([], 0).
len([_|T], L) :-
    len(T, L1),
    L is L1 + 1.

app([], L, L).
app([H1|T1], L, [H1|R]) :-
    app(T1, L, R).
    
sum([H], H).
sum([H|T], S) :-
    sum(T, S1),
    S is S1 + H.

at(1, [H|_], H).
at(N, [_|T], E) :-
    at(N1, T, E),
    N is N1 + 1.

count(_, [], 0).
count(E, [H|T], C) :-
    E == H,
    count(E, T, C1),
    C is C1 + 1.
count(E, [H|T], C) :-
    E \= H,
    count(E, T, C).