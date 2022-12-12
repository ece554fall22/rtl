onerror {resume}
quietly set dataset_list [list sim vsim]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/data_cache_tb_top/inf/dut_hit
add wave -noupdate sim:/data_cache_tb_top/inf/dut_dirty
add wave -noupdate sim:/data_cache_tb_top/inf/dut_dirty_array
add wave -noupdate sim:/data_cache_tb_top/inf/dut_plru
add wave -noupdate sim:/data_cache_tb_top/inf/dut_tag_out
add wave -noupdate sim:/data_cache_tb_top/inf/dut_data_out
add wave -noupdate sim:/data_cache_tb_top/inf/dut_valid_array
add wave -noupdate sim:/data_cache_tb_top/inf/flushtype
add wave -noupdate -divider {New Divider}
add wave -noupdate sim:/data_cache_tb_top/TB_SUB_INST/clk
add wave -noupdate sim:/data_cache_tb_top/TB_SUB_INST/rst
add wave -noupdate sim:/data_cache_tb_top/inf/access_type
add wave -noupdate sim:/data_cache_tb_top/inf/w
add wave -noupdate sim:/data_cache_tb_top/inf/r
add wave -noupdate sim:/data_cache_tb_top/inf/r_index
add wave -noupdate sim:/data_cache_tb_top/inf/r_line
add wave -noupdate sim:/data_cache_tb_top/inf/r_tag
add wave -noupdate sim:/data_cache_tb_top/inf/w_tag
add wave -noupdate sim:/data_cache_tb_top/inf/w_index
add wave -noupdate sim:/data_cache_tb_top/inf/w_line
add wave -noupdate sim:/data_cache_tb_top/inf/w_way
add wave -noupdate sim:/data_cache_tb_top/inf/dut_way
add wave -noupdate sim:/data_cache_tb_top/inf/w_data
add wave -noupdate sim:/data_cache_tb_top/inf/w_tagcheck
add wave -noupdate sim:/data_cache_tb_top/inf/no_tagcheck_read
add wave -noupdate sim:/data_cache_tb_top/inf/no_tagcheck_way
add wave -noupdate sim:/data_cache_tb_top/inf/DATA_ARRAY
add wave -noupdate sim:/data_cache_tb_top/inf/TAG_ARRAY
add wave -noupdate -divider {New Divider}
add wave -noupdate sim:/data_cache_tb_top/inf/data_block
add wave -noupdate sim:/data_cache_tb_top/inf/tag_block
add wave -noupdate sim:/data_cache_tb_top/inf/metadata_block
add wave -noupdate sim:/data_cache_tb_top/inf/perf_data_out
add wave -noupdate sim:/data_cache_tb_top/inf/perf_dirty
add wave -noupdate sim:/data_cache_tb_top/inf/perf_hit
add wave -noupdate sim:/data_cache_tb_top/inf/perf_tag_out
add wave -noupdate sim:/data_cache_tb_top/inf/perf_way
add wave -noupdate sim:/data_cache_tb_top/inf/pre_write_procedure_done
add wave -noupdate sim:/data_cache_tb_top/inf/update_metadata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 311
configure wave -valuecolwidth 197
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {189 ns}
