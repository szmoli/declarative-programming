p(1).
p(2).
p(X) :- X > 1.

m(2, 0).
m(1, 2).
m(1, 3).
m(2, 1).
m(_, 4).

q(X) :- m(_, X), p(X).
        
% (a) ?- select(1, [2,X,3], L).
% X = 1, L = [2,3]
% (b) ?- atom_codes(abc, [_|L]), atom_codes(X, L).
% L = ['b, 'c], X = bc
% (c) ?- \+ \+ X = 1, X = 2.
% X = 2
% (d) ?- m(1, X).
X = 2; X = 3; X = 4
% (e) ?- q(X).
% m(_, X), p(X) -> X = 2; X = 2; X = 3; X = 1; X = 4