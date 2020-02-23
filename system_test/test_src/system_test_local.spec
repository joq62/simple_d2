{test_files,[{computer_handler,stop},
	     {computer_handler,start},
	     {computer_handler,stop}
	    ]}.

{apps,[{{service,"dns_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"master_computer"}},
       {{service,"iaas_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"master_computer"}},
       {{service,"log_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"w1_computer"}},
       {{service,"adder_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"w1_computer"}},
       {{service,"adder_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"w2_computer"}},
       {{service,"adder_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"w12_computer"}}
      ]}.

{computers,[{"master_computer",'master_computer@asus',"localhost",42000},
	    {"w1_computer",'w1_computer@asus',"localhost",50001},
	    {"w2_computer",'w2_computer@asus',"localhost",50002},
	    {"w3_computer",'w3_computer@asus',"localhost",50003},
	    {"w10_computer",'w10_computer@asus',"localhost",51001},
	    {"w11_computer",'w11_computer@asus',"localhost",51002},
	    {"w12_computer",'w12_computer@asus',"localhost",51003}
	   ]}.
{source,{dir,"/home/pi/erlang/d/source"}}.
