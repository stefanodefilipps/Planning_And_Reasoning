FLOW OF EXECUTION

--- 1) Launch the file init_map.m
	In this file we define the map and the rooms as vertices and the formula to be satisfied as a string

--- 2) Launch the file triangulation_init.m
	In this file the triangulation is executed and the main file for NuMSV file is created. As output this file
	creates the file "numsv_main.smv"

--- 3) Launch ./NuSMV -int  (It opens interactive shell of NuMSV)

--- 4) NuSMV > process_model -i path_to_model (path to numsv_main.smv file)

--- 5) NuSMV > show_traces -o path_to_file_where_to_write_traces_output (in my case i called the file output.txt)

--- 6) Launch the file parse_out_traces.m to plot the generated path before and after smoothing