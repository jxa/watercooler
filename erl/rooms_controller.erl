-module(rooms_controller).
-export([out/1]).

layout(Content) ->
    {ehtml, [{html, [], 
             {body, [], Content}}]}.

out(Arg) ->
    layout([{h1, [], "Rooms"},
            {ul, [], rooms_list()}]).

rooms_list() ->
    [{li, [], Name} || Name <- room:all_names()].
