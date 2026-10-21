module SPI_master(
input clk,              // System clock
input rst,
input start,           // Start transmission
input [7:0] data_in,    // Data to send
input miso,             // Data from slave

output reg sclk,        // SPI clock
output reg ss,          // Slave select
output reg mosi,        // Data to slave

output reg [7:0] data_out, // Received byte
output reg busy,
output reg done
    );
    reg [6:0] count;
 
    //////////////////////////////////////////////////
// State Encoding
//////////////////////////////////////////////////
localparam S0 = 4'd0,
           S1 = 4'd1,
           S2 = 4'd2,
           S3 = 4'd3,
           S4 = 4'd4,
           S5 = 4'd5,
           S6 = 4'd6,
           S7 = 4'd7,
           S8 = 4'd8,
           S9 = 4'd9;

//////////////////////////////////////////////////
// State Registers
//////////////////////////////////////////////////
reg [3:0] state, next_state;
reg [7:0] shift_tx;
reg [7:0] shift_rx;
reg transfer_active;
always @(posedge clk or posedge rst)
begin
    if(rst)
        transfer_active <= 1'b0;
    else if(start)
        transfer_active <= 1'b1;
    else if(state == S9)
        transfer_active <= 1'b0;
end
always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        count <= 7'd0;
        sclk  <= 1'b0;
    end
    else if (transfer_active)
    begin
        if (count == 7'd49)
        begin
            count <= 7'd0;
            sclk  <= ~sclk;
        end
        else
        begin
            count <= count + 1'b1;
        end
    end
    else
    begin
        // Idle state
        count <= 7'd0;
        sclk  <= 1'b0;
    end
end



//////////////////////////////////////////////////
// 1. State Register
//////////////////////////////////////////////////
always @(posedge sclk or posedge rst) begin
    if (rst)begin
            state <= S0;
            shift_tx<=0;
            shift_rx<=0;
        end
    else
    begin
        state <= next_state;
        // Latch data once when transmission starts
        if(state == S0 && start)begin
            shift_tx <= data_in;
            shift_rx <= 0;
            end
        case(state)
            S1:begin
             shift_rx[0] <= miso;

             end
                
            S2: begin shift_rx[1] <= miso;

             end
            S3: begin shift_rx[2] <= miso;
        
             end
            S4: begin shift_rx[3] <= miso;
          
             end
            S5: begin shift_rx[4] <= miso;
          
             end
            S6: begin shift_rx[5] <= miso;
           
             end
            S7: begin shift_rx[6] <= miso;
           
             end
            S8: begin shift_rx[7] <= miso;
           
             end
            default: ;
        endcase
    end
end
//////////////////////////////////////////////////
// Next-State Logic
//////////////////////////////////////////////////
always @(*)
begin
next_state = state;
  
    
    case(state)
        // Idle
        S0:
        begin
            
            if(start)
                next_state = S1;
        end
        // Data bit 0
        S1:
        begin
            
                next_state = S2;
        end

        // Data bit 1
        S2:
        begin
            
                next_state = S3;
        end
        // Data bit 2
        S3:
        begin
            
                next_state = S4;
        end
        // Data bit 3
        S4:
        begin
            
                next_state = S5;
        end
        // Data bit 4
        S5:
        begin
            
                next_state = S6;
        end
        // Data bit 5
        S6:
        begin
            
                next_state = S7;
        end
        // Data bit 6
        S7:
        begin
            
                next_state = S8;
        end
        // Data bit 7
        S8:
        begin
            
                next_state = S9;
        end
        S9: next_state=S0;
        default:
            next_state = S0;
    endcase
end

//////////////////////////////////////////////////
// Output Logic
//////////////////////////////////////////////////
always @(*)
begin
    ss=1;     
    done = 1'b0;
    data_out=0;
    busy= (state != S0);
    case(state) 
        S1:
        begin
        ss=0;         
        end
        S2:
        begin
        ss=0;      
                   end
        S3:
        begin
        ss=0;          
        end
        S4:
        begin
        ss=0;                          
        end
        S5:
        begin
        ss=0;                 
        end
        S6:
        begin
        ss=0;               
        end
        S7:
        begin
        ss=0;                  
        end
        S8:
        begin
        ss=0;              
        end
        S9:
        begin 
        ss=0;
            done=1'b1;
            data_out=shift_rx;
            
            end
    endcase
end
always @(negedge sclk or posedge rst)
begin
    if(rst)
        mosi <= 1'b0;
    else
    begin
        case(state)
            S1: mosi <= shift_tx[0];
            S2: mosi <= shift_tx[1];
            S3: mosi <= shift_tx[2];
            S4: mosi <= shift_tx[3];
            S5: mosi <= shift_tx[4];
            S6: mosi <= shift_tx[5];
            S7: mosi <= shift_tx[6];
            S8: mosi <= shift_tx[7];
            default: mosi <= 1'b0;
        endcase
    end
end
endmodule
