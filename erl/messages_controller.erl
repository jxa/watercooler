-module(messages_controller).
-include("/usr/local/lib/yaws/include/yaws_api.hrl").
-export([out/1]).

layout(Content) ->
    {ehtml, [{html, [], 
             {body, [], Content}}]}.

out(A) ->
    Req = A#arg.req,
    Method = Req#http_request.method,
    Path = string:tokens(A#arg.appmoddata, "/"),
    io:format("~p - ~p~n",[Method, Req#http_request.path]),
    handle_request(Method, Path, A).

handle_request('GET', [], _) ->
    MsgList = message:all(),
    H2 = "All Rooms",
    format_list(H2, MsgList);

handle_request('GET', [Room|_], Arg) ->
    case yaws_api:queryvar(Arg, "newer_than") of
        {ok, I}  -> 
            case string:to_integer(I) of
                {error, _} -> MsgList = [];
                {ID, _}    -> MsgList = message:all(Room, newer_than, ID)
            end;
        _ -> MsgList = message:all(Room, limit, 30)
    end,
%    H2 = "In Room: " ++ Room,
    messages_json(MsgList);
%    format_list(H2, MsgList);

handle_request('POST', [Room|_], Arg) ->
    {ok, Auth} = yaws_api:postvar(Arg, "author"),
    {ok, Body} = yaws_api:postvar(Arg, "body"),
    {ok, Type} = yaws_api:postvar(Arg, "type"),
    io:format("Author: ~p~nType: ~p~nBody: ~p~n", [Auth, Type, Body]),
    message:create(Room, Type, Auth, Body),
    [{status, 200}];

handle_request(_, _, _Arg) -> % catchall
    [{status, 501}].

format_list(H2, MsgList) ->
    layout([{h1, [], "Messages"},
            {h2, [], H2},
            {ul, [], messages_list(MsgList)}]).

messages_json(List) ->
%    MJ = [ {struct, [{"author",A}, {"type",T}, {"body",B}] }  || {_, _, _, T, A, B, _Timestamp} <- List],
    MJ = [ {struct, [{"author",A}, {"body",B}, {"id", ID}] }  || {_, ID, _Room, _Type, A, B, _Timestamp} <- List],
    {html, json:encode({array, MJ})}.

messages_list(List) ->
    [{li, [], Auth ++ ": " ++ Msg} || {_, _, _, _, Auth, Msg, _} <- List].
