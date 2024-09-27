proc xapp888_create_project {} {

create_project xapp888_plle2  -force xapp888_plle2 -part xc7k325tffg900-2
add_files -norecurse {plle2_drp_func.h plle2_drp.v top_plle2.v  top_plle2.xdc}
import_files -force -norecurse
import_files -fileset sim_1 -norecurse {top_plle2_tb.v}
update_compile_order -fileset sim_1
}
