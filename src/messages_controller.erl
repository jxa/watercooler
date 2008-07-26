-module(messages_controller).
-include("/usr/local/lib/yaws/include/yaws_api.hrl").
-export([handle_request/3]).

handle_request('GET', [], _) ->
    MsgList = message:all(limit, 30),
    messages_json(MsgList);

handle_request('GET', [Room|_], Arg) ->
    case yaws_api:queryvar(Arg, "newer_than") of
        {ok, I}  -> 
            case string:to_integer(I) of
                {error, _} -> MsgList = [];
                {ID, _}    -> MsgList = message:all(Room, newer_than, ID)
            end;
        _ -> MsgList = message:all(Room, limit, 30)
    end,
    messages_json(MsgList);

handle_request('POST', [Room|_], Arg) ->
    {ok, Auth} = yaws_api:postvar(Arg, "author"),
    {ok, Body} = yaws_api:postvar(Arg, "body"),
    {ok, Type} = yaws_api:postvar(Arg, "type"),
    io:format("Author: ~p~nType: ~p~nBody: ~p~n", [Auth, Type, Body]),
    message:create(Room, Type, Auth, Body),
    [{status, 200}];

handle_request(_, _, _Arg) -> % catchall
    [{status, 501}].

messages_json(List) ->
    MJ = [ {struct, [{"author",A}, {"body",B}, {"id", ID}] }  || {_, ID, _Room, _Type, A, B, _Timestamp} <- List],
    {html, json:encode({array, MJ})}.
