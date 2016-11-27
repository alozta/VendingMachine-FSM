library verilog;
use verilog.vl_types.all;
entity vending_machine is
    port(
        mode            : in     vl_logic;
        ent             : in     vl_logic;
        res             : in     vl_logic;
        pswrd           : in     vl_logic_vector(0 to 3);
        mon             : in     vl_logic_vector(0 to 2);
        it_no           : in     vl_logic_vector(0 to 3);
        \rem\           : in     vl_logic;
        add_mon         : in     vl_logic;
        err_pswrd       : out    vl_logic;
        err_it_no       : out    vl_logic;
        suc_it_no       : out    vl_logic;
        suc_rem         : out    vl_logic;
        state           : out    vl_logic_vector(0 to 4);
        all_led         : out    vl_logic_vector(0 to 9)
    );
end vending_machine;
