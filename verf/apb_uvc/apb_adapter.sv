class apb_adapter extends uvm_reg_adapter;
    `uvm_object_utils(apb_adapter)
    
    function new(string name = "apb_adapter");
        super.new(name);
    endfunction

    function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
        apb_tr tr;
        tr = apb_tr::type_id::create("tr");
        tr.addr   = rw.addr;
        tr.data   = rw.data;
        tr.wr_en  = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
        return tr;
    endfunction 

    function void bus2reg (uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        apb_tr tr;
        if (!$cast(tr, bus_item)) begin
            `uvm_fatal("APB_ADAPTER", "Invalid bus item type not of type apb_tr")
        end
        rw.addr = tr.addr;
        rw.data = tr.data;
        rw.kind = (tr.wr_en == 1'b1) ? UVM_WRITE : UVM_READ;
    endfunction
endclass