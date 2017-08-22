`timescale 1ns / 1ps
//`define test;

module debouncer (                         
    `ifdef test     
                    input       i_rst,               
                                i_btn,
                                i_clock,
                                
                    output reg  led_press,
                                led_release
    `else
                    input       i_rst_n,
                                i_key,
                                i_clk,
                    
                    output reg  o_press,
                                o_release
    `endif              
                 );

localparam 
            UP      = 4'b0001, 
            FILLTER0  = 4'b0010, 
            DOWN      = 4'b0100, 
            FILLTER1  = 4'b1000;
    
reg [19:0]  cnt;
reg [3:0]   state;
 
reg         start_cnt,

            key_in_sa, 
            key_in_sb,
            
            key_tmpa, 
            key_tmpb;


wire pedge, nedge;


//////////////////////////////////////////////////////////////
////////////////////TEST_BLOCK_XILINX_cmodA7//////////////////
//////////////////////////////////////////////////////////////            
`ifdef test                    
reg    o_press,
       o_release;

wire i_key;
wire i_rst_n;
wire i_clk;


clk_wiz_0 clk_wiz_0 (.clk_in1(i_clock), .clk_out1(i_clk));

 
assign i_rst_n = ~i_rst;
assign i_key   = ~i_btn;


always @(posedge i_clk, negedge i_rst_n)
 if (~i_rst_n) begin
  
    led_press <= 1'b0;
    led_release <= 1'b0;
    
end else begin
        case(1'b1) 
            o_press: 
                       begin
                          led_press <= 1;
                          led_release <= 0;
                       end
            o_release:  
                       begin
                          led_press <= 0;
                          led_release <= 1;
                       end
            default:
                       begin
                          led_press <= led_press;
                          led_release <= led_release;
                       end
         endcase
                          
end
    
`endif
//////////////////////////////////////////////////////////////
//////////////////////end_TEST_BLOCK_XILINX_cmodA7////////////
//////////////////////////////////////////////////////////////


always @( posedge i_clk, negedge i_rst_n )
    
    if( ~i_rst_n ) begin
        
        key_in_sa <= 1'b0;
        key_in_sb <= 1'b0;
    
    end else begin
    
        key_in_sa <= i_key;
        key_in_sb <= key_in_sa;
    
    end
    


always @(posedge i_clk, negedge i_rst_n)

    if(~i_rst_n) begin

        key_tmpa <= 1'b0;
        key_tmpb <= 1'b0;

    end else begin

        key_tmpa <= key_in_sb;
        key_tmpb <= key_tmpa;

    end

       
assign nedge = !key_tmpa & key_tmpb;
assign pedge =  key_tmpa & (!key_tmpb);   


always @(posedge i_clk, negedge i_rst_n)

    if(~i_rst_n) begin

    state <= UP;
    start_cnt <= 1'b0;
    o_press <= 1'b0;
    o_release <= 1'b0;

end else begin

    case(state)

                UP:   
                        begin
                                o_press <= 1'b0;
                                o_release <= 1'b0;
                            if(nedge) begin
                                state <= FILLTER0;
                                start_cnt <= 1'b1;
                            end else
                                state <= UP;
                        end
            
                FILLTER0:   
                        if(cnt == 1000000) begin
                            o_press <= 1'b1;
                            start_cnt <= 1'b0;
                            state <= DOWN;
                            end else if(pedge) begin
                                state <= UP;
                                start_cnt <= 1'b0;
                            end else
                                state <=FILLTER0;
            
                DOWN:   
                         begin
                            o_press <= 1'b0;
                            o_release <= 1'b0;
                         if(pedge) begin
                            state <= FILLTER1;
                            start_cnt <= 1'b1;
                         end else
                            state <= DOWN;
                         end
            
                FILLTER1:   
                         if(cnt == 1000000) begin
                            o_release <= 1'b1;
                            start_cnt <= 1'b0;
                            state <= UP;
                         end else if(nedge) begin
                            state <= DOWN;
                            start_cnt <= 1'b0;
                         end else
                            state <=FILLTER1;
            
                 default:
                         begin
                             state <= UP;
                             start_cnt <= 1'b0;
                             o_press <= 1'b0;
                             o_release <= 1'b0;
                         end                       
        endcase
end    


always @(posedge i_clk, negedge i_rst_n)

    if(~i_rst_n)

        cnt <= 20'b0;

    else if (start_cnt)

        cnt <= cnt + 1'b1;

    else

        cnt <= 20'b0;

endmodule