%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% search.pl  –  Project 6, Question 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% State is state(Room, Keys)
%   Room = current room number
%   Keys = list of colors we already collected

search(Actions) :-
    initial(StartRoom),
    treasure(GoalRoom),
    bfs([[state(StartRoom, []), []]], GoalRoom, RevActions),
    reverse(RevActions, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Breadth–First Search over state(Room,Keys)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If current room is the goal, we are done
bfs([[state(Room, Keys), Actions] | _], Room, Actions).

% Otherwise expand this state and continue with rest of queue
bfs([[State, Actions] | RestQueue], Goal, ResultActions) :-
    findall(
        [NextState, [Act | Actions]],
        next(State, Act, NextState),
        NewPairs
    ),
    append(RestQueue, NewPairs, NewQueue),
    bfs(NewQueue, Goal, ResultActions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transitions: next(State, Action, NextState)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1) Move through an ordinary door (undirected graph)
next(state(R, Ks), move(R, N), state(N, Ks)) :-
    door(R, N).
next(state(R, Ks), move(R, N), state(N, Ks)) :-
    door(N, R).

% 2) Move through a locked door only if we already have the key
next(state(R, Ks), move(R, N), state(N, Ks)) :-
    locked_door(R, N, Color),
    member(Color, Ks).
next(state(R, Ks), move(R, N), state(N, Ks)) :-
    locked_door(N, R, Color),
    member(Color, Ks).

% 3) Pick up a key in the current room
next(state(R, Ks), unlock(Color), state(R, NewKs)) :-
    key(R, Color),
    \+ member(Color, Ks),
    NewKs = [Color | Ks].
