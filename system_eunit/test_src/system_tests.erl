%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : 
%%% Three computers 
%%% {"pod_computer_1", "localhost",40100,parallell, 40101, 10}
%%% {"pod_computer_2", "localhost" 40200,parallell, 40201, 10}
%%% {"pod_computer_3", "localhost" 40300,parallell, 40301,10}
%%% Each pod has its port number as vm name pod_40101@asus
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(system_tests). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include("common_macros.hrl").
-include("system_tests.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]).



%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
cases_test()->
    [ets_start(),
     clean_start(),
     eunit_start(),
     % Add funtional test cases 
     system_test_cases:start_computer_pods(),
     system_test_cases:start_dns(),
     system_test_cases:store_app_files(),
     system_test_cases:start_apps(),
     system_test_cases:update_dns(),
     system_test_cases:test_adder_divi(),
     % cleanup and stop eunit 
     stop_computer_pods(),
     clean_stop(),
     eunit_stop()].


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    spawn(fun()->eunit:test({timeout,30,system}) end).



ets_start()->
    ?ETS=ets:new(?ETS,[public,set,named_table]),
    {ok,Info}=file:consult("node.config"),
    ?assertEqual({computer_list,
		  [{"pod_master","localhost",40000,parallell},
		   {"pod_landet_1","localhost",50100,parallell},
		   {"pod_lgh_1","localhost",40100,parallell},
		   {"pod_lgh_2","localhost",40200,parallell}]},lists:keyfind(computer_list,1,Info)),

    {computer_list,ComputerConfig}=lists:keyfind(computer_list,1,Info),
    ComputerInfoList=[system_test_cases:create_vm_info(CInfo)||CInfo<-ComputerConfig],
    ets:insert(?ETS,{computer_list,ComputerInfoList}),
    [ets:insert(?ETS,{Cid,CInfo})||{Cid,CInfo}<-ComputerInfoList],
  
    ComputerVmList=[{CInfo#computer_info.vm_name,CInfo#computer_info.vm}||{_Cid,CInfo}<-ComputerInfoList],
    ets:insert(?ETS,{computer_vm_list,ComputerVmList}),
%    ?assertEqual(glurk,ets:lookup(?ETS,computer_list)),
%    ?assertEqual(glurk,ets:lookup(?ETS,"pod_landet_1")),
 %   ?assertEqual(glurk,ets:tab2list(?ETS)),
    ok. 


clean_start()->
    [{_,ComputerVmList}]=ets:lookup(?ETS,computer_vm_list),
    [rpc:call(Vm,init,stop,[])||{_,Vm}<-ComputerVmList],
    [pod:delete(node(),VmName)||{VmName,_}<-ComputerVmList],
    start_service(lib_service),
    check_started_service(lib_service),
    
    ok.
eunit_start()->
    [].

clean_stop()->
   
    ok.

stop_computer_pods()->
    [{_,ComputerVmList}]=ets:lookup(?ETS,computer_vm_list),
    [pod:delete(node(),VmName)||{VmName,_}<-ComputerVmList].

eunit_stop()->
    [
     stop_service(lib_service),
     timer:sleep(1000),
     init:stop()].

%% --------------------------------------------------------------------
%% Function:support functions
%% Description: Stop eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

start_service(Service)->
    ?assertEqual(ok,application:start(Service)).
check_started_service(Service)->
    ?assertMatch({pong,_,Service},Service:ping()).
stop_service(Service)->
    ?assertEqual(ok,application:stop(Service)),
    ?assertEqual(ok,application:unload(Service)).

