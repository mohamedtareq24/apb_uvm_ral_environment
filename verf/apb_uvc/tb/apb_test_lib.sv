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

    virtual task reset_phase(uvm_phase phase);
        #100ns; // Wait for 100ns to ensure reset is applied
    endtask

endclass



