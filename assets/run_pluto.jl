
# Parsing ARGS
notebook_input, depot_input, unsaved_notebooks_dir = ARGS

notebook = isempty(notebook_input) ? nothing : notebook_input
depot = isempty(depot_input) ? nothing : depot_input

# https://github.com/fonsp/Pluto.jl/commit/7bbdc7b55bd5149a9eb92cdfc2b540464dc32626
ENV["JULIA_PLUTO_NEW_NOTEBOOKS_DIR"] = unsaved_notebooks_dir

# We modify the LOAD_PATH of this process to only include the active project (created for this app), not the global project.
copy!(LOAD_PATH, ["@"])
import Pkg; Pkg.instantiate()


# Make sure that all logs go to stdout instead of stderr.
import Logging
Logging.global_logger(Logging.ConsoleLogger(stdout));


import Pluto

# The Pluto desktop app might have been launched with an ENV value set for JULIA_DEPOT_PATH. If so, then the user wants this special DEPOT path, so we should make sure that notebook processes use that value.
# But! This script was launched by our node process with a custom ENV value for JULIA_DEPOT_PATH, because this Pluto server should use our dedicated DEPOT (distributed in our app). The original ENV value is passed in as command line argument, so that we can reset it here.

# We do this by modifying the ENV dictionary in this Julia process (the server process). (When Distributed creates child processes, the value of `ENV` is used.) This will not modify DEPOT_PATH on this process 👍.
if depot === nothing
    delete!(ENV, "JULIA_DEPOT_PATH")
else
    ENV["JULIA_DEPOT_PATH"] = depot
end

# Here we go!
Pluto.run(; notebook, launch_browser=false, port_hint=7122)

