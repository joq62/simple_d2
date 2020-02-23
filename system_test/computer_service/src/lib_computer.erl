%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(lib_computer). 
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
-define(FILES_KEEP,["computer_service","Makefile","log_file",
		       "src","ebin","test_src","test_ebin"]).

-define(SERVICES_2_PRELOAD,["tcp_service","log_service",
			    "local_dns_service"]).
%% External exports

%-export([boot/6]).

-compile(export_all).

%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
boot({ComputerIpAddr,ComputerPort},VmMinPort,VmMaxPort,Type,Source)->
    {ok,_}=scratch(?FILES_KEEP),
    {ok,VmStartInfo}=start_vms(VmMinPort,VmMaxPort-VmMinPort,[]),
 %   {ok,Result}=load_start_services(?SERVICES_2_PRELOAD,[]),
    VmStartInfo.


%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
load_start_services(Vm,Type,Source,DestinationDir,EnvVariables)->
    load_start_services(?SERVICES_2_PRELOAD,
			Vm,Type,Source,DestinationDir,EnvVariables,
			[]).
load_start_services([],_Vm,_Type,_Source,_DestinationDir,_EnvVariables,Result)->
    Result;
load_start_services([ServiceId|T],Vm,Type,Source,DestinationDir,EnvVariables,Acc) ->
    R=service_handler:start(Vm,ServiceId,Type,Source,DestinationDir,EnvVariables),
    ok.


%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
start_vms(_VmMinPort,-1,VmList)->
    {ok,VmList};
start_vms(VmMinPort,N,Acc) ->
    Port=N+VmMinPort,
    VmId=integer_to_list(Port)++"_vm",
    Vm=vm_handler:create(VmId),
    NewAcc=[{VmId,Vm,Port}|Acc],
    start_vms(VmMinPort,N-1,NewAcc).
%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
scratch()->
    scratch(?FILES_KEEP).
scratch(FilesKeep)->
    {ok,Files}=file:list_dir("."),
    Result=[{File,os:cmd("rm -r "++File)}||File<-Files,
			     false==lists:member(File,FilesKeep)],
    {ok,Result}.


%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
