// default timescale
-timescale 1ps/1fs


+incdir+./
+incdir+./tb
+incdir+../if
+incdir+../../src
+incdir+./reg_verifier_dir/uvmreg

./reg_verifier_dir/uvmreg/cdns_uvmreg_utils_pkg.sv
./reg_verifier_dir/uvmreg/apb_wrapper_regs_rdb.sv

../if/apb_if.sv
../../src/apb_wrapper.sv
./apb_pkg.sv
./tb/apb_tb_top.sv
