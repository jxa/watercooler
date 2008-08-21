-module(wc_user).
-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").
-compile(export_all).

%% TODO: encrypt passwords

-record(user, {username, realname, email, password}).

init() ->
    mnesia:create_table(user, [{attributes, record_info(fields, user)}]).

load() ->
    Users = [{"ch0wda", "Josh Schairbaum", "ch@wda.com", "foobar"},
             {"jxa", "John Andrews", "j@hn.com", "barfoo"}],
    [create(U,R,E,P) || {U,R,E,P} <- Users],
    ok.

reset() ->
    mnesia:delete_table(user).

create(Username, Realname, Email, Password) ->
    User = #user{username=Username, 
                 realname=Realname,
                 email=Email,
                 password=Password},
    base:create(User).

find(Username) ->
    base:find(qlc:q([User || User <- mnesia:table(user),
                             User#user.username =:= Username])).

login(Uname, Pass) ->
    case find(Uname) of
        none   -> bad_user;
        [User] -> password_match(User, Pass);
        Val    -> bad_user
    end.

password_match(User, Pass) ->
    if User#user.password =:= Pass -> ok;
       true -> no_password_match
    end.

% create tests only if eunit is present and enabled
-ifdef(EUNIT).
test_setup() ->
    mnesia:start(),
    init(),
    load().
password_match_test_() ->
  [?_assertEqual(ok, password_match(#user{password="pass"}, "pass")),
   ?_assertEqual(no_password_match, password_match(#user{password="pass"}, "wrong"))
  ].
login_test_() ->
    {setup, local,
     fun test_setup/0,
     fun(_) -> reset() end,
     fun login_tests/1}.
login_tests(_) ->
    [?_assertEqual(ok, login("jxa", "barfoo")),
     ?_assertEqual(bad_user, login("noexist", "null"))].

-endif.
