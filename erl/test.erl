-module(test).
%%-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").
-include("test.hrl").
-compile(export_all).

init() ->
    mnesia:create_table(message,
                        [{attributes, record_info(fields, message)}]),
    mnesia:create_table(room,
                        [{attributes, record_info(fields, room)}]),
    mnesia:create_table(sequence,
                        [{attributes, record_info(fields, sequence)}]),
    Seq = #sequence{seq = message, next_id = 1},
    create(Seq).

reset() ->
    mnesia:delete_table(message),
    mnesia:delete_table(sequence),
    mnesia:delete_table(room).


create_room(Name, Subject) ->
    Room = #room{name = Name, subject = Subject},
    create(Room).

rooms() ->
    find_all(room).

log_message(Room, Type, Author, Body) ->
    ID = next_id(message),
    Message = #message{id=ID, room=Room, type=Type, author=Author, body=Body},
    create(Message).

messages() ->
    find_all(message).

create(Row) ->
    Fun = fun()->
                  mnesia:write(Row)
          end,
    mnesia:transaction(Fun).

find(Q) ->
    F = fun() ->
                 qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.


find_all(Table) ->
    find(qlc:q([R || R <- mnesia:table(Table)])).

next_id(Table) ->
    F = fun() ->
                %% Get next id in the sequence
                [{_,_,N}] = find(qlc:q([X || X <- mnesia:table(sequence), X#sequence.seq =:= Table])),
                %% increment the sequence
                mnesia:write({sequence, Table, N+1}),
                N
        end,
    {atomic, ID} = mnesia:transaction(F),
    ID.

% create tests only if eunit is present and enabled
-ifdef(EUNIT).

-endif.
