set script_dir [file dirname [info script]]
set project_name "spinal_gowin_project"
set project_dir [file join $script_dir $project_name]

# create project if it doesn't exist yet
create_project -name $project_name -dir $script_dir -pn GW1NR-LV9QN88PC6/I5 -device_version NA -force

# add generated HDL files + constraints
foreach f [glob ../../../gen/*.v] {
  import_files $f
}

import_files ../../constraints/tang_nano_9k.cst

# open project and run all
open_project [file join [pwd] $project_dir $project_name.gprj]
run all
