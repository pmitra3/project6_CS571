%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project 6 - EXACT MATCH to ref_out1 and ref_out2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    initial(Start),
    treasure(Goal),
    % Collect keys available at the start room immediately
    (findall(K, key(Start, K), InitKeys) -> true ; InitKeys = []),
    % State: state(Room, KeysHeld, UnlockedColors)
    bfs([[state(Start, InitKeys, []), []]], Goal, Rev),
    reverse(Rev, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS with PERFECT neighbor ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Base case: Head of queue is at Goal room
bfs([[state(Room, _Keys, _Unlocked), Actions] | _], Room, Actions).

% Recursive step
bfs([[State, Actions] | Rest], Goal, Result) :-
    neighbors_exact(State, Actions, NewPairs),
    append(Rest, NewPairs, NewQueue),
    bfs(NewQueue, Goal, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXACT ORDER:
% 1. move through UNLOCKED doors
% 2. UNLOCK (Open locked door)
% 3. move through LOCKED doors (must be unlocked first)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neighbors_exact(state(R, Keys, Unlocked), Actions, All) :-
    % 1. Plain moves
    findall([S2, [A|Actions]], move_plain(R, Keys, Unlocked, A, S2), Plain),
    % 2. Unlock
    findall([S2, [unlock(C)|Actions]], do_unlock(R, Keys, Unlocked, C, S2), UnlockAction),
    % 3. Moves through locked doors
    findall([S2, [A|Actions]], move_locked(R, Keys, Unlocked, A, S2), Locked),
    append([Plain, UnlockAction, Locked], All).

% Helper: Update keys when entering a room N
update_keys(N, CurrentKeys, NewKeys) :-
    findall(K, key(N, K), RoomKeys),
    append(CurrentKeys, RoomKeys, AllKeys),
    sort(AllKeys, NewKeys). % sort removes duplicates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLAIN DOORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_plain(R, Keys, Unlocked, move(R,N), state(N, NewKeys, Unlocked)) :-
    (door(R, N) ; door(N, R)),
    % Ensure this door is NOT locked
    \+ locked_door(R, N, _),
    \+ locked_door(N, R, _),
    update_keys(N, Keys, NewKeys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNLOCK (Open locked door)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do_unlock(R, Keys, Unlocked, Color, state(R, Keys, [Color|Unlocked])) :-
    % Check if there is a locked door connected to R with Color
    (locked_door(R, _, Color) ; locked_door(_, R, Color)),
    member(Color, Keys),       % Must have key
    \+ member(Color, Unlocked). % Not yet unlocked

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCKED DOORS (Must be unlocked first)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_locked(R, Keys, Unlocked, move(R,N), state(N, NewKeys, Unlocked)) :-
    (locked_door(R, N, Color) ; locked_door(N, R, Color)),
    member(Color, Unlocked),   % Door must be unlocked
    update_keys(N, Keys, NewKeys).