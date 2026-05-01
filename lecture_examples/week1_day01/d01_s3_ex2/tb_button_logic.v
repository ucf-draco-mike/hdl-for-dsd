// =============================================================================
// tb_button_logic.v -- Smoke testbench for button_logic
// =============================================================================
`timescale 1ns/1ps

module tb_button_logic;
    reg  s1, s2, s3, s4;
    wire l1, l2, l3, l4;

    button_logic dut (
        .i_switch1(s1), .i_switch2(s2), .i_switch3(s3), .i_switch4(s4),
        .o_led1(l1), .o_led2(l2), .o_led3(l3), .o_led4(l4)
    );

    integer fails = 0;
    task check(input [255:0] name, input ok);
        if (!ok) begin
            $display("FAIL: %0s", name);
            fails = fails + 1;
        end else
            $display("PASS: %0s", name);
    endtask

    initial begin
        $dumpfile("tb_button_logic.vcd");
        $dumpvars(0, tb_button_logic);

        s1=0; s2=0; s3=0; s4=0; #10;
        check("all=0: l1=0,l2=1,l3=0,l4=0", l1===0 && l2===1 && l3===0 && l4===0);

        s1=1; s2=1; s3=0; s4=0; #10;
        check("s1=s2=1: l3=AND=1", l3===1);

        s1=0; s2=1; s3=0; s4=0; #10;
        check("s2=1: l2=NOT(1)=0", l2===0);

        s3=1; s4=0; #10;
        check("xor s3=1,s4=0: l4=1", l4===1);

        s3=1; s4=1; #10;
        check("xor s3=1,s4=1: l4=0", l4===0);

        if (fails == 0) $display("=== 5 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
