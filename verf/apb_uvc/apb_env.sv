class apb_env extends uvm_env;
    `uvm_component_utils(apb_env)
    
    apb_agent apb_agt;

    apb_wrapper_regs_t apb_reg_model;
    uvm_reg_predictor#(apb_tr) apb_predictor;
    apb_adapter adapter;
    string hdl_path_root;

    function new(string name = "apb_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(string)::get(this, "", "hdl_path_root", hdl_path_root)) begin
            `uvm_fatal("APB_ENV", "HDL path root not found in config db")
        end
        super.build_phase(phase);
        // Create APB agent
        apb_agt = apb_agent::type_id::create("apb_agt", this);
        // Create register model
        apb_reg_model = apb_wrapper_regs_t::type_id::create("apb_reg_model", this);
        apb_reg_model.build();
        apb_reg_model.lock_model();
        apb_reg_model.set_hdl_path_root(this.hdl_path_root);        // we can use a config object here 
        // Create register adapter
        adapter = apb_adapter::type_id::create("adapter", this);
        //apb_reg_model.apb_map.set_auto_predict(1);
        // Create register predictor
        apb_predictor = uvm_reg_predictor#(apb_tr)::type_id::create("apb_predictor", this);
        `uvm_info("APB_ENV", "Build phase complete", UVM_MEDIUM)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        apb_reg_model.apb_map.set_sequencer(apb_agt.sequencer , adapter);
        apb_agt.apb_ap.connect(apb_predictor.bus_in);
        apb_predictor.map = apb_reg_model.apb_map;
        apb_predictor.adapter = adapter;

        `uvm_info("APB_ENV", "Connect phase complete", UVM_MEDIUM)
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("APB_ENV", "APB Register Model:", UVM_LOW)
		apb_reg_model.print();
    endfunction
endclass