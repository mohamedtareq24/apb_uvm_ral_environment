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