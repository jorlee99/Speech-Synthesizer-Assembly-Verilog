onerror {exit -code 1}
vlib work
vlog -work work simple_ipod_solution.vo
vlog -work work ipod_fsm_timer_tb.vwf.vt
vsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.ipod_fsm_timer_vlg_vec_tst -voptargs="+acc"
vcd file -direction simple_ipod_solution.msim.vcd
vcd add -internal ipod_fsm_timer_vlg_vec_tst/*
vcd add -internal ipod_fsm_timer_vlg_vec_tst/i1/*
run -all
quit -f
