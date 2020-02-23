%% This is the application resource file (.app file) for the 'base'
%% application.
{application, computer_service,
[{description, "computer_service" },
{vsn, "0.0.1" },
{modules, [computer_service_app,computer_service_sup,
	   computer_service]},
{registered,[computer_service]},
{applications, [kernel,stdlib]},
{mod, {computer_service_app,[]}},
{start_phases, []}
]}.
