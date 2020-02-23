%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(boot_service).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
-define(FILES_TO_KEEP,["boot_service","Makefile","src","ebin",
		       "test_src","test_ebin"]).
-define(SERVICES_TO_LOAD,["tcp_service","log_service","local_dns_service"]).
%% External exports


-export([start/4
	]).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
start(Ip,Port,Type,Source)->
    _IpStr=atom_to_list(Ip),
    _P=list_to_integer(atom_to_list(Port)),
    _SourceStr=atom_to_list(Source),
 %   clean_up(?FILES_TO_KEEP),
    case Type of
	dir->
	    ok;
	github->
	    ok
    end,    
    init:stop().


%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
%filter_events(Key
clean_up(Keep)->
    Result=case file:list_dir(".") of
	       {ok,Files}->
		   FilesToDelete=file_to_delete(Files,Keep,Files),
		   delete_files(FilesToDelete),
		   ok;
	       {error,Err} ->
		   {error,Err}
	   end,
    Result.


file_to_delete([],_Keep,FilesToDelete)->
    FilesToDelete;
file_to_delete(_Files,[],FilesToDelete)->
    FilesToDelete;
file_to_delete([File|T],Keep,Acc)->
   % io:format("~p~n",[{?MODULE,?LINE,File,Keep,Acc}]),
    NewAcc= case lists:member(File,Keep)of 
		true->
		    lists:delete(File,Acc);
		false->
		    Acc
	    end,
    file_to_delete(T,Keep,NewAcc).
    

delete_files([])->
    ok;
delete_files([File|T])->
    io:format("~p~n",[{?MODULE,?LINE,"rm -rf "++File}]),
   % os:cmd("rm -rf "++File),
    timer:sleep(100),
    delete_files(T).
