In order to write the counter proof pn a txt file run the following commands:

./NuSMV -int  (It opens interactive shell of NuMSV)

NuSMV > process_model -i path_to_model
NuSMV > show_traces -o opath_to_file_where_to_write  


If i am only try to reach a goal while avoiding obstacle so the formula is !(o1 | o2 ...) U pi

then it is better to use bounded model checking. we can do this by doing:

--- ./NuSMV -int path_to_model
--- NuSMV > go_bmc
--- NuSMV > check_ltlspec_bmc_onepb -k 20
--- NuSMV > show_traces -o opath_to_file_where_to_write


otherwise the loop try to go back to the starting point
