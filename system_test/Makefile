build_test:
	rm -rf /home/pi/erlang/d/source/test_client/src/*~;
	rm -rf /home/pi/erlang/d/source/test_client/ebin/*.beam;
	rm -rf /home/pi/erlang/d/source/test_client/*.dump;
	rm -rf /home/pi/erlang/d/source/test_client/test_ebin/*;
	cp /home/pi/erlang/d/source/tcp_service/src/*.erl /home/pi/erlang/d/source/test_client/src;
	cp /home/pi/erlang/d/source/tcp_service/src/*.app test_ebin;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/test_client/src;
	cp /home/pi/erlang/d/source/test_client/src/*.app test_ebin;
	erlc -o test_ebin /home/pi/erlang/d/source/test_client/src/*.erl;
	erlc -o test_ebin /home/pi/erlang/d/source/test_client/test_src/*.erl;
	erl -pa test_ebin -s local_test_client_test start -sname test_client
local:
	rm -rf computer_service test_src/*~ test_src/*.beam *.dump;
	rm -rf test_ebin/* ebin/*;
	mkdir computer_service;
	cp -r /home/pi/erlang/d/source/computer_service/* computer_service;
#	cp /home/pi/erlang/d/source/computer_service/src/*.app test_ebin;	
	cp /home/pi/erlang/d/source/include/*.hrl computer_service/ebin;
	erlc -o computer_service/ebin computer_service/src/*.erl;
#	copy common macros tpeach src dir 
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/adder_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/iaas_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/log_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/computer_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/dns_service/src;
	erlc -D system_test -D local  -I test_src  -o test_ebin test_src/*.erl;
	erl -pa test_ebin -pa computer_service/ebin -pa * -s system_test start test_src/system_test_local.spec -sname system_test_local
glurk_public:
	rm -rf test_src/*~ test_src/*.beam *.dump;
	rm -rf test_ebin/* ebin/*;
	cp /home/pi/erlang/d/source/lib_service/src/*.* test_src;
	cp /home/pi/erlang/d/source/lib_service/src/*.app test_ebin;	
	cp /home/pi/erlang/d/source/include/*.hrl test_src;	
#	copy common macros tpeach src dir 
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/adder_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/catalog_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/iaas_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/lib_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/log_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/master_service/src;
	cp /home/pi/erlang/d/source/include/*.hrl /home/pi/erlang/d/source/dns_service/src;
	erlc -D system_test -D public  -I test_src  -o test_ebin test_src/*.erl;
	erl -pa test_ebin -pa * -s system_test start system_test_public.spec -sname system_test_public
