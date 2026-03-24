# apb_uvm_ral_environment
A reusbale UVM RAL environment for practicing RAL in UVM 
works as an extenstion to the Elastic Buffer Project

### APB RAL Wrapper Testbench

The APB wrapper provides an APB (Advanced Peripheral Bus) interface to configure and monitor the Elastic Buffer. This testbench verifies:
- APB read/write transactions
- Register access (configuration and status)
- Protocol compliance
- Register functionality


## Register Map
The APB wrapper implements the following registers at base address `0xA000_0000`:

| Offset | Name             | Access | Description                    |
|--------|------------------|--------|--------------------------------|
| 0x00   | EB_CTRL          | RW     | Enable control [0]             |
| 0x04   | EB_COR_CFG_MAX   | RW     | Max threshold [5:0]            |
| 0x08   | EB_COR_CFG_MIN   | RW     | Min threshold [5:0]            |
| 0x0C   | EB_COR_SEQ1      | RW     | Correction sequence 1 [19:0]   |
| 0x10   | EB_COR_SEQ2      | RW     | Correction sequence 2 [19:0]   |
| 0x14   | EB_FILL_LEVEL    | RO     | Current fill level [5:0]       |
| 0x18   | EB_SKP_ADD_CNT   | RO     | SKP add counter [15:0]         |
| 0x1C   | EB_SKP_RM_CNT    | RO     | SKP remove counter [15:0]      |
| 0x20   | EB_SKP_EVENT     | RO     | SKP event flags [1:0]          |
| 0x24   | EB_ERR_STATUS    | RO     | Error status [2:0]             |

## APB UVC Overview
This environment includes a reusable APB UVC integrated with UVM RAL for register-centric verification of the APB wrapper.

## RAL Features Documentation
### Key Features
- Automated model generation from IP-XACT XML file using cadence reg-verifier
- Dual access paths are available through APB frontdoor transactions and HDL-path backdoor access.
- RAL abstraction decouples register intent from bus protocol, with bus-specific logic isolated in the adapter/UVC.
  
- Explicit prediction updates the mirror from observed bus traffic using monitor plus predictor connectivity.
- Pre-defined RAL sequences are included for reset checks, bit-bash, access checks, and HDL path validation.

## UVC Topology:
```
-------------------------------------------------------------------
Name                       Type                         Size  Value
-------------------------------------------------------------------
uvm_test_top               apb_ral_bit_bash_test        -     @2911
  env                      apb_env                      -     @2972
    apb_agt                apb_agent                    -     @3032
      apb_ap               uvm_analysis_port            -     @4332
      driver               apb_driver                   -     @3518
        rsp_port           uvm_analysis_port            -     @3618
        seq_item_port      uvm_seq_item_pull_port       -     @3567
      monitor              apb_monitor                  -     @4233
        ap                 uvm_analysis_port            -     @4388
      sequencer            apb_sequencer                -     @3597
        rsp_export         uvm_analysis_export          -     @3706
        seq_item_export    uvm_seq_item_pull_imp        -     @4254
        arbitration_queue  array                        0     -    
        lock_queue         array                        0     -    
        num_last_reqs      integral                     32    'd1  
        num_last_rsps      integral                     32    'd1  
    apb_predictor          uvm_reg_predictor #(apb_tr)  -     @3296
      bus_in               uvm_analysis_imp             -     @3415
      reg_ap               uvm_analysis_port            -     @3466
-------------------------------------------------------------------
```
## Register model based on: [docs/eb_apb_registers_ipxact.xml](docs/eb_apb_registers_ipxact.xml)

```
UVM_INFO apb_env.sv(45) @ 0: uvm_test_top.env [APB_ENV] APB Register Model:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Name                   Type                                                                   Size  Value                                                                                           
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
apb_reg_model          elastic_buffer_apb_regs_vendor_mohamed_tarek_library_flat_version_1_0  -     @3052                                                                                           
  apb_map_eb_regs      T_eb_regs_24                                                           -     @3076                                                                                           
    EB_COR_CFG_MAX     T_EB_COR_CFG_MAX_15                                                    -     @3112                                                                                           
      cor_max          uvm_reg_field                                                          ...    RW EB_COR_CFG_MAX[5:0]=6'h00                                                                   
    EB_COR_CFG_MIN     T_EB_COR_CFG_MIN_16                                                    -     @3122                                                                                           
      cor_min          uvm_reg_field                                                          ...    RW EB_COR_CFG_MIN[5:0]=6'h00                                                                   
    EB_COR_SEQ1        T_EB_COR_SEQ1_17                                                       -     @3138                                                                                           
      cor_seq1         uvm_reg_field                                                          ...    RW EB_COR_SEQ1[19:0]=20'h00000                                                                 
    EB_COR_SEQ2        T_EB_COR_SEQ2_18                                                       -     @3153                                                                                           
      cor_seq2         uvm_reg_field                                                          ...    RW EB_COR_SEQ2[19:0]=20'h00000                                                                 
    EB_CTRL            T_EB_CTRL_14                                                           -     @3168                                                                                           
      enable           uvm_reg_field                                                          ...    RW EB_CTRL[0:0]=1'h0                                                                           
    EB_ERR_STATUS      T_EB_ERR_STATUS_23                                                     -     @3183                                                                                           
      err_status       uvm_reg_field                                                          ...    RO EB_ERR_STATUS[2:0]=3'h0                                                                     
    EB_FILL_LEVEL      T_EB_FILL_LEVEL_19                                                     -     @3198                                                                                           
      fill_level       uvm_reg_field                                                          ...    RO EB_FILL_LEVEL[5:0]=6'h00                                                                    
    EB_SKP_ADD_CNT     T_EB_SKP_ADD_CNT_20                                                    -     @3213                                                                                           
      skp_add_cnt      uvm_reg_field                                                          ...    RO EB_SKP_ADD_CNT[15:0]=16'h0000                                                               
    EB_SKP_EVENT       T_EB_SKP_EVENT_22                                                      -     @3228                                                                                           
      skp_drop_evt     uvm_reg_field                                                          ...    RO EB_SKP_EVENT[0:0]=1'h0                                                                      
      skp_add_evt      uvm_reg_field                                                          ...    RO EB_SKP_EVENT[1:1]=1'h0                                                                      
    EB_SKP_RM_CNT      T_EB_SKP_RM_CNT_21                                                     -     @3243                                                                                           
      skp_rm_cnt       uvm_reg_field                                                          ...    RO EB_SKP_RM_CNT[15:0]=16'h0000                                                                
    apb_map            uvm_reg_map                                                            0     id=@3065 seqr=uvm_test_top.env.apb_agt.sequencer offset=0x0 size=0xa000001e baseaddr=0x0        
      apb_map_eb_regs  uvm_reg_map                                                            0     id=@3102 seqr=uvm_test_top.env.apb_agt.sequencer offset=0xa0000000 size=0x1d baseaddr=0xa0000000
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
```