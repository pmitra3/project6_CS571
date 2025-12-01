%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parsing for Project 6 – CS571
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse(Tokens) :-
    lines(Tokens, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lines → Line ; Lines | Line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lines(Input, Rest) :-
    line(Input, More),
    ( More = [';' | Next] ->
        lines(Next, Rest)
    ; Rest = More ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line → Num , Line | Num
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

line(Input, Rest) :-
    num(Input, More),
    ( More = [',' | Next] ->
        line(Next, Rest)
    ; Rest = More ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Num → Digit | Digit Num
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num([D|Rest], More) :-
    digit(D),
    digits(Rest, More).

digits([D|Rest], More) :-
    digit(D), !,
    digits(Rest, More).
digits(More, More).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Digit → 0 | ... | 9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

digit('0'). digit('1'). digit('2').
digit('3'). digit('4'). digit('5').
digit('6'). digit('7'). digit('8').
digit('9').
