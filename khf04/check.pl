% Készítette: Szmoleniczki Ákos, YL2JJ2 (szmoleniczki.akos@edu.bme.hu)
% Dátum: 2025-11-02

% use_module(library(lists)).

% Row is the Nth row of Matrix.
row(Matrix, Nth, Row) :-
	nth1(Nth, Matrix, Row).
    
% Col is the Nth col of Matrix.
column(Matrix, Nth, Col) :-
	maplist(nth1(Nth), Matrix, Col).
	
% Size is the size of Matrix.
size(Matrix, Size) :- 
    length(Matrix, Size).

% range(Start, End, Number) :-
%     integer(Start),
%     integer(End),
%     Start =< End,
%     range_recursive(Start, End, Number).
% 
% range_recursive(Cur, End, Cur) :-
%     Cur =< End.
% range_recursive(Cur, End, Num) :-
%     Cur < End,
%     Next is Cur + 1,
%     range_recursive(Next, End, Num).

% Zeros is the number of zeros in each column or row.
% Zeros = Size - M.
zeros(M, Matrix, Zeros) :-
    integer(M),
    size(Matrix, Size),
    integer(Size),
    Zeros is Size - M.

% Checks if List is has Zeros amount of zeros and each number between 1..M exactly once.
correct_list(M, ExpectedZeros, List) :-
    length(List, Len),
    count(0, List, ActualZeros),
    ActualZeros =:= ExpectedZeros,
    Len =:= M + ActualZeros,
    exclude(==(0), List, WithoutZeros),
    numlist(1, M, Expected),
    msort(WithoutZeros, Sorted),
    Sorted == Expected.

% Count is the number of Elements in List.
count(_, [], 0).
count(Element, [Element|T], Count) :-
    count(Element, T, C),
    Count is C + 1.
count(Element, [H|T], Count) :- 
    count(Element, T, Count),
    Element \= H.

% List is Matrix flattened in the order of helix traversal.
helix(Matrix, Flattened) :-
    size(Matrix, Size),
    integer(Size),
    Top is 1,
    Left is 1,
    Bottom is Size,
    Right is Size,
    helix_recursive(Top, Left, Bottom, Right, Matrix, [], Flattened).

% Flattened is the flattened submatrix of Matrix given by the boundries Top, Left, Bottom, Right.
% Base case.
helix_recursive(Top, Left, Bottom, Right, _Matrix, Acc, Acc) :-
    Bottom < Top,
    Right < Left.

% 2x2 case.
helix_recursive(Top, Left, Bottom, Right, Matrix, Acc, Result) :- 
    Bottom =:= Top + 1,
    Right =:= Left + 1,
    element(Matrix, Top, Left, Element1),
    element(Matrix, Top, Right, Element2),
    element(Matrix, Bottom, Right, Element3),
    element(Matrix, Bottom, Left, Element4),
    append(Acc, [Element1, Element2, Element3, Element4], Result).

% 1x1 case.
helix_recursive(Top, Left, Bottom, Right, Matrix, Acc, Result) :- 
    Bottom =:= Top,
    Right =:= Left,
    element(Matrix, Top, Left, Element),
    append(Acc, [Element], Result).

% Result is the flattened submatrix of Matrix given by the boundries Top, Left, Bottom, Right.
helix_recursive(Top, Left, Bottom, Right, Matrix, Acc, Result) :-
    row(Matrix, Top, TopRow),
    row(Matrix, Bottom, BottomRow),
    column(Matrix, Left, LeftColumn),
    column(Matrix, Right, RightColumn),
    Top1 is Top + 1,
    Bottom1 is Bottom - 1,
    Left1 is Left + 1,
    Right1 is Right - 1,
    slice(TopRow, Left, Right, TopRowSegment),
    slice(BottomRow, Left, Right, BottomRowSegment),
    slice(RightColumn, Top1, Bottom1, RightColumnSegment),
    slice(LeftColumn, Top1, Bottom1, LeftColumnSegment),
    reverse(BottomRowSegment, ReversedBottomRowSegment),
    reverse(LeftColumnSegment, ReversedLeftColumnSegment),
    append([TopRowSegment, RightColumnSegment, ReversedBottomRowSegment, ReversedLeftColumnSegment], Helix),
    append(Acc, Helix, NewAcc),
    helix_recursive(Top1, Left1, Bottom1, Right1, Matrix, NewAcc, Result).

% Element is the element of Matrix at (Row, Col).
element(Matrix, Row, Column, Element) :-
    nth1(Row, Matrix, R),
    nth1(Column, R, Element).

% Slice is the slice from Start to End of List.
slice(List, Start, End, Slice) :-
    findall(Element, 
            (between(Start, End, Index), 
                nth1(Index, List, Element)), 
            Slice).   

% Sequence is a list of the numbers 1..M N times.
sequence(N, M, Sequence) :-
    sequence(N, M, [], Sequence).

sequence(0, _, Acc, Acc). 
sequence(N, M, Acc, Sequence) :-
    N > 0,
    numlist(1, M, Pattern),
    append(Acc, Pattern, NewAcc),
    N1 is N - 1,
    sequence(N1, M, NewAcc, Sequence).

% Checks if Matrix is a valid solution to the helix problem given by M.
tekercsekk(M, Matrix) :-
    size(Matrix, Size),
    zeros(M, Matrix, ExpectedZeros),
    findall(Row, 
        (between(1, Size, Nth),
        row(Matrix, Nth, Row),
        correct_list(M, ExpectedZeros, Row)),
        Rows
    ),
    size(Rows, CorrectRowCount),
    CorrectRowCount =:= Size,
    findall(Column, 
        (between(1, Size, Nth),
        column(Matrix, Nth, Column),
        correct_list(M, ExpectedZeros, Column)),
        Columns
    ),
    size(Columns, CorrectColumnCount),
    CorrectColumnCount =:= Size,
    helix(Matrix, Helix),
    exclude(==(0), Helix, HelixWithoutZeros),
    sequence(Size, M, Sequence),
    HelixWithoutZeros == Sequence.
