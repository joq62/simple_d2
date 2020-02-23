%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
-module(computer_service_app).
 
-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 start/2,
	 stop/1
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------


%% ====================================================================!
%% External functions
%% ====================================================================!
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _StartArgs) ->
    {ok,{Ip,Port}}=application:get_env(computer_ip_address_port),
    ComputerIpAddr=atom_to_list(Ip),
    ComputerPort=list_to_integer(atom_to_list(Port)),
    {ok,Min}=application:get_env(min_vm_port),
    MinVmPort=list_to_integer(atom_to_list(Min)),
    {ok,Max}=application:get_env(max_vm_port),
    MaxVmPort=list_to_integer(atom_to_list(Max)),
    {ok,Type}=application:get_env(type),
    {ok,S}=application:get_env(source),
    Source=atom_to_list(S),
    
    Args=[{ComputerIpAddr,ComputerPort},{MinVmPort,MaxVmPort},
	  {Type,Source}],

    {ok,Pid}= computer_service_sup:start(Args),
    {ok,Pid}.
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
    ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

