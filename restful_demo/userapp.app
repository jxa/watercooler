{application, userapp, [
  {description, "A RESTful user-store."},
  {vsn, "0.1"},
  {modules, [userapp, userapp_sup, userapp_server]},
  {registered, [userapp]},
  {env, [
    {port, 8007},
    {working_dir, "/Users/ja/bt/watercooler/restful_demo/"}
  ]},
  {applications, [kernel, stdlib, sasl]},
  {mod, {userapp, []}},
  {start_phases, [
    {mnesia, []}
  ]}
]}.
