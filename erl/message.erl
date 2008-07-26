-module(message).
%%-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").
-compile(export_all).

-record(message, {id, room, type, author, body, created_at}).

init() ->
    mnesia:create_table(message,
                        [{attributes, record_info(fields, message)}]),
    sequence:create(message).

load() ->
        Msgs = [{"braintree", msg, "xandrews", "hello"},
            {"braintree", msg, "ch0wda", "what up"},
            {"braintree", msg, "xandrews", "nothing"},
            {"braintree", msg, "ch0wda", "ok"},
            {"braintree", status, "system", "ch0wda has left"},
            {"developers", msg, "ch0wda", "halloo"}],
    [create(R,T,A,B) || {R,T,A,B} <- Msgs],
    ok.

reset() ->
    mnesia:delete_table(message).

create(Room, Type, Author, Body) ->
    ID = sequence:next(message),
    TS = erlang:localtime(),
    Message = #message{id=ID, room=Room, type=Type, author=Author, body=Body, created_at = TS},
    base:create(Message).

all() ->
    base:find_all(message).

all(limit, Limit) ->
    QH = qlc:q([Msg || Msg <- mnesia:table(message)]),
    Msgs = base:limit(QH, Limit),
    lists:sort(Msgs).

all(Room, limit, Limit) ->
    QH = qlc:q([Msg || Msg <- mnesia:table(message), Msg#message.room =:= Room]),
    Msgs = base:limit(QH, Limit),
    lists:sort(Msgs);

all(Room, newer_than, ID) ->
    QH = qlc:q([Msg || Msg <- mnesia:table(message),
                       Msg#message.room =:= Room,
                       Msg#message.id > ID]),
    base:find(QH).

% create tests only if eunit is present and enabled
-ifdef(EUNIT).

-endif.
