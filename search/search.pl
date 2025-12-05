%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project 6 - Updated for Bug Fix (No Unlock Actions)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    initial(Start),
    treasure(Goal),
    % 1. Collect initial keys
    (findall(K, key(Start, K), InitKeys) -> true ; InitKeys = []),
    
    % State: state(Room, KeysHeld)
    StartState = state(Start, InitKeys),
    
    % BFS with Visited list
    bfs([[StartState, []]], [StartState], Goal, Rev),
    reverse(Rev, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Base case: Head of queue is at Goal room
bfs([[state(Room, _Keys), Actions] | _], _, Room, Actions).

% Recursive step
bfs([[State, Actions] | Rest], Visited, Goal, Result) :-
    neighbors(State, Actions, NewPairs),
    % Filter out states that have already been visited
    filter_visited(NewPairs, Visited, NewQueueItems, NewVisited),
    append(Rest, NewQueueItems, NewQueue),
    bfs(NewQueue, NewVisited, Goal, Result).

% Helper to filter visited states
filter_visited([], Visited, [], Visited).
filter_visited([[State, Acts]|Rest], Visited, [[State, Acts]|NewRest], FinalVisited) :-
    \+ member(State, Visited), !,
    filter_visited(Rest, [State|Visited], NewRest, FinalVisited).
filter_visited([_|Rest], Visited, NewRest, FinalVisited) :-
    filter_visited(Rest, Visited, NewRest, FinalVisited).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEIGHBORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neighbors(state(R, Keys), Actions, All) :-
    findall([S2, [move(R, N)|Actions]], try_move(R, N, Keys, S2), All).

% Helper: Update keys when entering a room N
update_keys(N, CurrentKeys, NewKeys) :-
    findall(K, key(N, K), RoomKeys),
    append(CurrentKeys, RoomKeys, AllKeys),
    sort(AllKeys, NewKeys). % sort removes duplicates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MOVE LOGIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Case 1: Plain door (Always allowed)
try_move(R, N, Keys, state(N, NewKeys)) :-
    (door(R, N) ; door(N, R)),
    update_keys(N, Keys, NewKeys).

% Case 2: Locked door (Allowed ONLY if we have the key)
try_move(R, N, Keys, state(N, NewKeys)) :-
    (locked_door(R, N, Color) ; locked_door(N, R, Color)),
    member(Color, Keys), % Check: Do we have the key?
    update_keys(N, Keys, NewKeys).