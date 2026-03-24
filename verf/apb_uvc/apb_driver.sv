class apb_driver extends uvm_driver#(apb_tr);
    `uvm_component_utils(apb_driver)
    
    virtual apb_if vif;
    apb_tr req;

    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("APB_DRV", "Virtual interface not found")
        end
    endfunction


    virtual task run_phase(uvm_phase phase);
        // Drive idle values from the clocking block domain.
        vif.drv_cb.psel    <= 1'b0;
        vif.drv_cb.penable <= 1'b0;
        vif.drv_cb.pwrite  <= 1'b0;
        vif.drv_cb.paddr   <= '0;
        vif.drv_cb.pwdata  <= '0;
        forever begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            `uvm_info(get_type_name(), $sformatf("Sent APB Transaction %s", req.stringify()), UVM_LOW)
            seq_item_port.item_done();
        end
    endtask

    // Drive transaction on APB bus
    task send_to_dut(apb_tr tr);
        // Setup phase
        @(vif.drv_cb);
        vif.drv_cb.psel    <= 1'b1;
        vif.drv_cb.pwrite  <= tr.wr_en;
        vif.drv_cb.paddr   <= tr.addr;
        vif.drv_cb.pwdata  <= tr.data;
        vif.drv_cb.penable <= 1'b0;
        
        // Access phase  
        @(vif.drv_cb);
        vif.drv_cb.penable <= 1'b1;

        @(vif.drv_cb);
        if (tr.wr_en == 0 && vif.drv_cb.pready == 1) begin        // For read transactions, capture the read data
            tr.data = vif.drv_cb.prdata;
        end
        vif.drv_cb.psel    <= 1'b0;
        vif.drv_cb.penable <= 1'b0;
    endtask

endclass