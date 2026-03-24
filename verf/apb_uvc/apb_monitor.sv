class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)
    virtual apb_if vif;
    uvm_analysis_port#(apb_tr) ap;
    apb_tr tr;
    function new(string name = "apb_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("APB_MON", "Virtual interface not found")
        end
        ap = new("ap", this);
    endfunction

    // Run Phase - Monitor APB transactions on the bus
    virtual task run_phase(uvm_phase phase);
        forever begin
            tr = apb_tr::type_id::create("tr");
            monitor_apb_transaction(tr);
            `uvm_info(get_type_name(), $sformatf("Monitored APB Transaction %s", tr.stringify()), UVM_LOW)
            // Write transaction to port
            ap.write(tr);
        end
    endtask

    // Monitor transactions from APB interface
    task monitor_apb_transaction(apb_tr tr);
        @(vif.mon_cb);
        wait(vif.mon_cb.psel === 1'b1);
        tr.addr  = vif.mon_cb.paddr;
        tr.wr_en = vif.mon_cb.pwrite;
        if (tr.wr_en == 1) begin
            tr.data = vif.mon_cb.pwdata;
        end
        
        @(vif.mon_cb);
        wait(vif.mon_cb.penable === 1'b1);

        @(vif.mon_cb);
        if (tr.wr_en == 0) begin
            tr.data = vif.mon_cb.prdata;
        end
    endtask

endclass