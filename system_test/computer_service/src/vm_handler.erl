%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(vm_handler). 
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Data Type
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------

-define(START_POD_INTERVAL,50).
-define(START_POD_TRIES,50).
-define(STOP_POD_INTERVAL,50).
-define(STOP_POD_TRIES,50).
%% External exports

-export([create/1,delete/1]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
create(VmId)->
    create_vm(VmId).
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
create_vm(VmId)->
    Result=case filelib:is_dir(VmId) of
	       true->
		   {error,[allready_exists,VmId,?MODULE,?LINE]};
	       false->
		   ok=file:make_dir(VmId),
		   start_vm(VmId)
	   end,
    Result.

start_vm(VmId)->
    ErlCmd="erl "++"-sname "++VmId++" -detached",
    Result= case os:cmd(ErlCmd) of
		[]->
		    {ok,Host}=inet:gethostname(),
		   NodeId=VmId++"@"++Host,
		    case check_if_vm_started(list_to_atom(NodeId),?START_POD_INTERVAL,?START_POD_TRIES,error) of
			error->
			    {error,[couldnt_start_pod,NodeId,?MODULE,?LINE]};
			ok->
			    list_to_atom(NodeId)
		    end;
	        {badrpc,Err}->
		    {error,[badrpc,Err,?MODULE,?LINE]};
		Err ->
		    {error,[unknown_error,Err,?MODULE,?LINE]}
	    end,
    Result.			

check_if_vm_started(_Vm,_Interval,0,ok)->
    ok;
check_if_vm_started(_Vm,_Interval,0,error)->
    error;
check_if_vm_started(_Vm,_Interval,_N,ok) ->
    ok;
check_if_vm_started(Vm,Interval,N,error) ->
    timer:sleep(Interval),
    case net_adm:ping(Vm) of
	pang->
	    NewResult=error;
	pong ->
	    NewResult=ok
    end,
    check_if_vm_started(Vm,Interval,N-1,NewResult).

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
delete(VmId)->
    delete_vm(VmId).

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
delete_vm(VmId)->
    {ok,Host}=inet:gethostname(),
    Vm=list_to_atom(VmId++"@"++Host),
    rpc:call(Vm,init,stop,[],5000),
    Result=case check_if_vm_stopped(Vm,?STOP_POD_INTERVAL,?STOP_POD_TRIES,error) of
	       error->
		   {error,[couldnt_stop_pod,VmId,?MODULE,?LINE]};
	       ok->
		   RmCmd="rm -rf "++VmId,
		   case os:cmd(RmCmd) of
		       []->
			   ok;
		       Err ->
			   {error,[unknown_error,Err,?MODULE,?LINE]}
		   end
	   end,
    Result.
		       


check_if_vm_stopped(_Vm,_Interval,0,ok)->
    ok;
check_if_vm_stopped(_Vm,_Interval,0,error)->
    error;
check_if_vm_stopped(_Vm,_Interval,_N,ok) ->
    ok;
check_if_vm_stopped(Vm,Interval,N,error) ->
    timer:sleep(Interval),
    case net_adm:ping(Vm) of
	pong->
	    NewResult=error;
	pang->
	    NewResult=ok
    end,
    check_if_vm_stopped(Vm,Interval,N-1,NewResult).
