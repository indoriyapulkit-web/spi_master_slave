module SPI_slave(
    input rst,
    input sclk,        // Clock from master
    input ss,          // Slave Select (active low)
    input mosi,        // Data from master
    input [7:0] data_in,   // Data to send to master

    output reg miso,       // Data sent to master
    output reg [7:0] data_out, // Data received from master
    output reg done
);

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
        if(state == S0 && !ss)
            shift_tx <= data_in;
        case(state)
            S1:begin
             shift_rx[0] <= mosi;

             end
                
            S2: begin shift_rx[1] <= mosi;

             end
            S3: begin shift_rx[2] <= mosi;
        
             end
            S4: begin shift_rx[3] <= mosi;
          
             end
            S5: begin shift_rx[4] <= mosi;
          
             end
            S6: begin shift_rx[5] <= mosi;
           
             end
            S7: begin shift_rx[6] <= mosi;
           
             end
            S8: begin shift_rx[7] <= mosi;
           
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
    if (ss)
        next_state = S0;
    else
    begin
    case(state)
        // Idle
        S0:
        begin
            if(!ss)
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
end
//////////////////////////////////////////////////
// Output Logic
//////////////////////////////////////////////////
always @(*)
begin  
    done = 1'b0;
    data_out=0;
    case(state)
        S9:
        begin 
            done=1'b1;
            data_out=shift_rx;
            end
    endcase
end
always @(negedge sclk or posedge rst)
begin
    if(rst)
        miso <= 1'b0;
    else
    begin
        case(state)
            S1: miso <= shift_tx[0];
            S2: miso <= shift_tx[1];
            S3: miso <= shift_tx[2];
            S4: miso <= shift_tx[3];
            S5: miso <= shift_tx[4];
            S6: miso <= shift_tx[5];
            S7: miso <= shift_tx[6];
            S8: miso <= shift_tx[7];
            default: miso <= 1'b0;
        endcase
    end
end
endmodule