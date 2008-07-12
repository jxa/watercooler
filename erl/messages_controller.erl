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
    case Path of
        [] -> 
            MsgList = message:all(),
            H2 = "All Rooms";
        [Room|_]  ->
            MsgList = message:all(Room, limit, 3),
            H2 = "In Room: " ++ Room
    end,
    layout([{h1, [], "Messages"},
            {h2, [], H2},
            {ul, [], messages_list(MsgList)}]).

messages_list(List) ->
    [{li, [], Auth ++ ": " ++ Msg} || {_, _, _, _, Auth, Msg, _} <- List].
