class apb_base_test extends uvm_test;
    `uvm_component_utils(apb_base_test)
    apb_env env;
    apb_base_seq apb_seq;
    function new(string name = "apb_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = apb_env::type_id::create("env", this);
        apb_seq = apb_base_seq::type_id::create("apb_seq");
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Printing Test Topology...", UVM_LOW)
        uvm_top.print_topology(); 
    endfunction

    
    virtual task configure_phase(uvm_phase phase);
        phase.raise_objection(this);
        // Start configuration sequence
        apb_seq.randomize();
        apb_seq.start(env.apb_agt.sequencer);
        phase.drop_objection(this);
    endtask

    
endclass

class apb_smoke_test extends apb_base_test;
    `uvm_component_utils(apb_smoke_test)

    function new(string name = "apb_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(apb_base_seq::get_type(), apb_config_seq::get_type());
        super.build_phase(phase);
    endfunction
endclass

virtual class apb_ral_test_base extends apb_base_test;
    `uvm_component_utils(apb_ral_test_base)
    typedef uvm_reg_sequence#(uvm_sequence#(uvm_reg_item)) uvm_ral_base_seq;
    uvm_ral_base_seq apb_ral_seq;
    uvm_status_e status;

    function new(string name = "apb_ral_test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        apb_ral_seq = uvm_ral_base_seq::type_id::create("apb_ral_seq");
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        apb_ral_seq.model = env.apb_reg_model;        
    endfunction

    virtual task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        #100ns; // Wait for 100ns to ensure reset is applied
        phase.drop_objection(this);
    endtask
    
    virtual task configure_phase(uvm_phase phase);
        phase.raise_objection(this);
        apb_ral_seq.randomize();
        apb_ral_seq.start(null);
        phase.drop_objection(this);
    endtask


endclass

class apb_ral_reset_test extends apb_ral_test_base;
    `uvm_component_utils(apb_ral_reset_test)

    function new(string name = "apb_ral_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(uvm_ral_base_seq::get_type(), uvm_reg_hw_reset_seq::get_type());
        super.build_phase(phase);
    endfunction
endclass

class apb_ral_reset_fault_test extends apb_ral_test_base;
    `uvm_component_utils(apb_ral_reset_fault_test)
    function new(string name = "apb_ral_reset_fault_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(uvm_ral_base_seq::get_type(), uvm_reg_hw_reset_seq::get_type());
        super.build_phase(phase);
    endfunction
    
    virtual task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        #100ns; // Wait for reset to deassert
        env.apb_reg_model.apb_map_eb_regs.EB_COR_SEQ2.poke(status, 32'h1);
        env.apb_reg_model.apb_map_eb_regs.EB_CTRL.poke(status, 32'h1);
        phase.drop_objection(this);
    endtask
endclass

class apb_ral_hdl_paths_test extends apb_ral_test_base;
    `uvm_component_utils(apb_ral_hdl_paths_test)

    function new(string name = "apb_ral_hdl_paths_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(uvm_ral_base_seq::get_type(), uvm_reg_mem_hdl_paths_seq::get_type());
        super.build_phase(phase);
    endfunction
endclass

class apb_ral_bit_bash_test extends apb_ral_test_base;
    `uvm_component_utils(apb_ral_bit_bash_test)

    function new(string name = "apb_ral_bit_bash_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(uvm_ral_base_seq::get_type(), uvm_reg_bit_bash_seq::get_type());
        super.build_phase(phase);
    endfunction
endclass

class apb_ral_reg_access_test extends apb_ral_test_base;
    `uvm_component_utils(apb_ral_reg_access_test)

    function new(string name = "apb_ral_reg_access_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(uvm_ral_base_seq::get_type(), uvm_reg_access_seq::get_type());
        super.build_phase(phase);
    endfunction
endclass

