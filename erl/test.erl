-module(test).
%%-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").
-include("test.hrl").
-compile(export_all).

init() ->
    mnesia:start(),
    mnesia:create_table(message,
                        [{attributes, record_info(fields, message)}]),
    mnesia:create_table(room,
                        [{attributes, record_info(fields, room)}]),
    mnesia:create_table(sequence,
                        [{attributes, record_info(fields, sequence)}]),
    Seq = #sequence{seq = message, next_id = 1},
    create(Seq).

load() ->
    Rooms = [{"braintree", "watercooler chat"},
             {"developers", "13375p33k 0n1y"}],
    Msgs = [{"braintree", msg, "xandrews", "hello"},
            {"braintree", msg, "ch0wda", "what up"},
            {"braintree", msg, "xandrews", "nothing"},
            {"braintree", msg, "ch0wda", "ok"},
            {"braintree", status, "system", "ch0wda has left"},
            {"developers", msg, "ch0wda", "halloo"}],
    [create_room(N,S) || {N,S} <- Rooms],
    [log_message(R,T,A,B) || {R,T,A,B} <- Msgs],
    ok.

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

messages(Room, Limit) ->
    QH = qlc:q([Msg || Msg <- mnesia:table(message), Msg#message.room =:= Room]),
    F = fun() ->
                %% use a cursor to grab only Limit records
                QC = qlc:cursor(QH),
                M = qlc:next_answers(QC, Limit),
                qlc:delete_cursor(QC),
                M
        end,
    {atomic, Msgs} = mnesia:transaction(F),
    Msgs.

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

%% actually returns the value of the next id
%% most recently used id is current_id -1
current_id(Table) ->
    [{_,_,ID}] = find(qlc:q([X || X <- mnesia:table(sequence), X#sequence.seq =:= Table])),
    ID.

next_id(Table) ->
    F = fun() ->
                %% Get next id in the sequence
                N = current_id(Table),
                %% increment the sequence
                mnesia:write({sequence, Table, N+1}),
                N
        end,
    {atomic, ID} = mnesia:transaction(F),
    ID.

% create tests only if eunit is present and enabled
-ifdef(EUNIT).

-endif.
