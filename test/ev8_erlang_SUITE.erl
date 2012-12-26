-module(ev8_erlang_SUITE).

-include_lib("common_test/include/ct.hrl").

-export([
  all/0,
  init_per_suite/1,
  end_per_suite/1
  ]).

-export([
  basic/1
  ]).

all() ->
  [basic].

init_per_suite(Config) ->
  erlang_v8:start(),
  Vm = ev8:new_vm(),
  Context = ev8:new_context(Vm),
  ev8:install(Context, [ev8_erlang]),
  [{vm, Vm}, {context, Context} | Config].

end_per_suite(Config) ->
  erlang_v8:stop(),
  Config.

basic(Config) ->
  C = ?config(context, Config),

  ev8:set(C, global, <<"myList">>, {"godzilla"}),

  hello_world = evo8:eval(C, <<"erlang.string_to_atom('hello_world')">>),
  "hello_world" = evo8:eval(C, <<"erlang.string_to_list('hello_world')">>),
  <<"mothra">> = evo8:eval(C, <<"erlang.atom_to_string(erlang.string_to_atom('mothra'))">>),
  <<"godzilla">> = evo8:eval(C, <<"erlang.list_to_string(myList)">>),
  [<<"hello">>, <<"world">>] = evo8:eval(C, <<"erlang.array_to_list(['hello', 'world'])">>),
  {<<"hello">>, <<"world">>} = evo8:eval(C, <<"erlang.array_to_tuple(['hello', 'world'])">>),
  [{<<"true">>, <<"hello">>},
   {<<"noo">>, false}] = evo8:eval(C, <<"erlang.object_to_proplist({true: 'hello', noo: false})">>),
  "hello, world" = evo8:eval(C, <<"erlang._apply('string', 'join', [[erlang.string_to_list('hello'), erlang.string_to_list('world')], erlang.string_to_list(', ')])">>),

  ok.