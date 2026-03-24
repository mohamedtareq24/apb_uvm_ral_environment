module apb_wrapper #(parameter DATA_WIDTH = 32 , ADDR_WIDTH = 32 , BASE_ADDR = 32'hA000_0000)(
        // APB Interface
        input   logic                       pclk_i        ,
        input   logic                       preset_n_i    ,
        input   logic                       psel_i        ,
        input   logic                       penable_i     ,
        output  logic                       pready_o      ,
        input   logic                       pwrite_i      ,
        input   logic   [DATA_WIDTH-1:0]    pwdata_i      ,
        input   logic   [ADDR_WIDTH-1:0]    paddr_i       ,
        output  logic   [DATA_WIDTH-1:0]    prdata_o      ,

        // Configuration Outputs (to Elastic Buffer)
        output  logic   [5:0]               cfg_cor_max_o,
        output  logic   [5:0]               cfg_cor_min_o,
        output  logic   [19:0]              cfg_cor_seq_val_1_o,
        output  logic   [19:0]              cfg_cor_seq_val_2_o,

        // Status Inputs (from Elastic Buffer)
        input   logic   [5:0]               stat_fill_level_i,
        input   logic   [15:0]              stat_cnt_add_i,
        input   logic   [15:0]              stat_cnt_drop_i,
        input   logic                       skp_add_evt_pulse_i,
        input   logic                       skp_drop_evt_pulse_i,
        input   logic   [2:0]               err_status_i
    );

    // Writable registers (RW)
    logic [DATA_WIDTH-1:0] reg_eb_ctrl;
    logic [DATA_WIDTH-1:0] reg_eb_cor_cfg_max;
    logic [DATA_WIDTH-1:0] reg_eb_cor_cfg_min;
    logic [DATA_WIDTH-1:0] reg_eb_cor_seq1;
    logic [DATA_WIDTH-1:0] reg_eb_cor_seq2;

    // Read-only registers (RO) - synthesized from status inputs
    logic [DATA_WIDTH-1:0] reg_eb_fill_level;
    logic [DATA_WIDTH-1:0] reg_eb_skp_add_cnt;
    logic [DATA_WIDTH-1:0] reg_eb_skp_rm_cnt;
    logic [DATA_WIDTH-1:0] reg_eb_skp_event;
    logic [DATA_WIDTH-1:0] reg_eb_err_status;

    // Register indices for address decoding
    localparam int unsigned REG_EB_CTRL        = 0;
    localparam int unsigned REG_EB_COR_CFG_MAX = 1;
    localparam int unsigned REG_EB_COR_CFG_MIN = 2;
    localparam int unsigned REG_EB_COR_SEQ1    = 3;
    localparam int unsigned REG_EB_COR_SEQ2    = 4;
    localparam int unsigned REG_EB_FILL_LEVEL  = 5;
    localparam int unsigned REG_EB_SKP_ADD_CNT = 6;
    localparam int unsigned REG_EB_SKP_RM_CNT  = 7;
    localparam int unsigned REG_EB_SKP_EVENT   = 8;
    localparam int unsigned REG_EB_ERR_STATUS  = 9;

    logic [ADDR_WIDTH-1:0] addr_offs;
    logic [7:0]            addr_word;

    assign addr_offs = paddr_i - BASE_ADDR;
    assign addr_word = addr_offs[9:2]; // word aligned (enough for this map)

    always_ff @( posedge pclk_i or negedge preset_n_i)
    begin
        if (!preset_n_i)
            pready_o <=  0 ;
        else 
            pready_o <=  1 ;
    end

    always_ff @(posedge pclk_i or negedge preset_n_i)
    begin
        if (!preset_n_i) begin
            reg_eb_ctrl         <= '0;
            reg_eb_cor_cfg_max  <= '0;
            reg_eb_cor_cfg_min  <= '0;
            reg_eb_cor_seq1     <= '0;
            reg_eb_cor_seq2     <= '0;
            reg_eb_fill_level   <= '0;
            reg_eb_skp_add_cnt  <= '0;
            reg_eb_skp_rm_cnt   <= '0;
            reg_eb_skp_event    <= '0;
            reg_eb_err_status   <= '0;
        end 
        else begin
            // Sample and synchronize status inputs into RO registers
            reg_eb_fill_level   <= {{(DATA_WIDTH-6){1'b0}},  stat_fill_level_i};
            reg_eb_skp_add_cnt  <= {{(DATA_WIDTH-16){1'b0}}, stat_cnt_add_i};
            reg_eb_skp_rm_cnt   <= {{(DATA_WIDTH-16){1'b0}}, stat_cnt_drop_i};
            reg_eb_skp_event    <= {{(DATA_WIDTH-2){1'b0}},  skp_add_evt_pulse_i, skp_drop_evt_pulse_i};
            reg_eb_err_status   <= {{(DATA_WIDTH-3){1'b0}},  err_status_i};

            if (psel_i && penable_i && pwrite_i) begin
                case (addr_word)
                    REG_EB_CTRL:        reg_eb_ctrl        <= {{(DATA_WIDTH-1){1'b0}}, pwdata_i[0]};
                    REG_EB_COR_CFG_MAX: reg_eb_cor_cfg_max <= {{(DATA_WIDTH-6){1'b0}}, pwdata_i[5:0]};
                    REG_EB_COR_CFG_MIN: reg_eb_cor_cfg_min <= {{(DATA_WIDTH-6){1'b0}}, pwdata_i[5:0]};
                    REG_EB_COR_SEQ1:    reg_eb_cor_seq1    <= {{(DATA_WIDTH-20){1'b0}}, pwdata_i[19:0]};
                    REG_EB_COR_SEQ2:    reg_eb_cor_seq2    <= {{(DATA_WIDTH-20){1'b0}}, pwdata_i[19:0]};
                    default: /* no-op */;
                endcase
            end
        end
    end

    always_comb begin
        prdata_o = '0;
        if (psel_i && penable_i && !pwrite_i) begin
            case (addr_word)
                REG_EB_CTRL:        prdata_o = reg_eb_ctrl;
                REG_EB_COR_CFG_MAX: prdata_o = reg_eb_cor_cfg_max;
                REG_EB_COR_CFG_MIN: prdata_o = reg_eb_cor_cfg_min;
                REG_EB_COR_SEQ1:    prdata_o = reg_eb_cor_seq1;
                REG_EB_COR_SEQ2:    prdata_o = reg_eb_cor_seq2;
                REG_EB_FILL_LEVEL:  prdata_o = reg_eb_fill_level;
                REG_EB_SKP_ADD_CNT: prdata_o = reg_eb_skp_add_cnt;
                REG_EB_SKP_RM_CNT:  prdata_o = reg_eb_skp_rm_cnt;
                REG_EB_SKP_EVENT:   prdata_o = reg_eb_skp_event;
                REG_EB_ERR_STATUS:  prdata_o = reg_eb_err_status;
                default:            prdata_o = '0;
            endcase
        end
    end

    // Drive configuration outputs from RW registers
    assign cfg_cor_max_o       = reg_eb_cor_cfg_max[5:0];
    assign cfg_cor_min_o       = reg_eb_cor_cfg_min[5:0];
    assign cfg_cor_seq_val_1_o = reg_eb_cor_seq1[19:0];
    assign cfg_cor_seq_val_2_o = reg_eb_cor_seq2[19:0];
endmodule