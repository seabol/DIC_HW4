module MPQ(clk,rst,data_valid,data,cmd_valid,cmd,index,value,busy,RAM_valid,RAM_A,RAM_D,done);
input clk;
input rst;
input data_valid;
input [7:0] data;
input cmd_valid;
input [2:0] cmd;
input [7:0] index;
input [7:0] value;
output reg busy;
output reg RAM_valid;
output reg[7:0]RAM_A;
output reg [7:0]RAM_D;
output reg done;
reg build, extract, increase, insert, write_1;
reg [7:0] index_1, index_heapify , largest , left , right, index_2, max, parent,increase_index, increase_value, index_heapify_1;
reg [7:0] data_in [0:254];
reg [4:0] nowstate, nextState;
integer i;
// index_1  heap.size
parameter Data_in = 5'd0,
        Control = 5'd1,
        build_queue = 5'd2,
        build_queue_1 = 5'd3,
        Max_heapify1   = 5'd4,
        Max_heapify2   = 5'd5,
        Max_heapify3 = 5'd6,
        Max_heapify4 = 5'd7,
        extract_max = 5'd8,
        Max_heapify_1 = 5'd9,
        Max_heapify_2 = 5'd10,
        Max_heapify_3 = 5'd11,
        Max_heapify_4 = 5'd12,
        increase_val = 5'd13,
        increase_val_1 = 5'd14,
        increase_val_2 = 5'd15,
        insert_data     = 5'd16,
        inser_data_1 = 5'd17,
        write = 5'd18,
        finish = 5'd19;

always @(posedge clk or posedge rst) begin
    if(rst) nowstate <= Data_in;
    else nowstate <= nextState;    
end


always @(posedge clk or posedge rst)begin
 if (rst) begin
        busy <= 1'b0;
        RAM_valid <= 1'b0;
        RAM_A <= 8'b0;
        RAM_D <= 8'b0;
        done <= 1'b0;
        build <= 1'b0;
        extract <= 1'b0;
        increase <= 1'b0;
        insert <= 1'b0;
        write_1 <= 1'b0;
        index_1 <= 8'b0;
        index_heapify <= 8'b0;
        largest <= 8'd0;
        left <= 8'b0;
        right <= 8'b0;
        index_2 <= 8'b0;
        max <= 8'b0;
        parent <= 8'b0;
        index_heapify_1 <=8'b0;
        increase_index <= 8'b0;
        increase_value <= 8'b0;
        for(i=0;i<255;i=i+1) begin
            data_in[i] <= 8'b0;
        end
 end
    else begin
        case(nowstate)
            Data_in:begin
                if (data_valid) begin
                    data_in[index_1] <= data;
                    index_1 <= index_1 + 1;
                    busy <= 1'b1;
                end
                else busy <= 1'b0;
            end
            Control:begin
                if (cmd==3'b0 && cmd_valid== 1'b1) begin
                    build <= 1'b1;
                    busy <= 1'b1;
                end
                else if (cmd==3'd1 && cmd_valid== 1'b1) begin
                    extract <= 1'b1;
                    busy <= 1'b1;
                end
                else if (cmd==3'd2 && cmd_valid== 1'b1) begin
                    increase <= 1'b1;
                    busy <= 1'b1;
                    increase_index <= index-1;
                    increase_value <= value;
                end
                else if (cmd==3'd3 && cmd_valid== 1'b1) begin
                    increase_value <= value;
                    insert <= 1'b1;
                    busy <= 1'b1;
                end
                else if (cmd==3'd4 && cmd_valid== 1'b1) begin
                    write_1 <= 1'b1;
                end
                else begin
                    build <= 1'b0;
                    extract <= 1'b0;
                    increase <= 1'b0;
                    insert <= 1'b0;
                    write_1 <= 1'b0;
                    busy <= 1'b0;
                end
            end
            build_queue:begin
                index_heapify_1 <= (index_1 >> 1);
                busy <= 1'b1;
            end
            build_queue_1:begin
            if (build) begin
                if (index_heapify_1!= 8'd0)  begin
                    index_heapify <= index_heapify_1;
                    busy <= 1'b1;
                end
                else begin
                    build <= 1'b0;
                    busy <= 1'b0;
                end
            end
            end
            Max_heapify1:begin
                left <= (2 * index_heapify)-1;
                right <= (2 * index_heapify);
            end
            Max_heapify2: begin
                if (((index_1 - 1) >= left ) && ( data_in[left] > data_in[index_heapify-1])) begin
                    largest <= left;
                end
                else largest <= index_heapify - 1;

            end
            Max_heapify3: begin
                if (((index_1 - 1) >= right  ) && (data_in[right] > data_in[largest])) begin
                    largest <= right;
                end
            end    
            Max_heapify4:begin   
                if (largest != index_heapify -1 ) begin
                    data_in[largest] <= data_in[index_heapify-1];
                    data_in[index_heapify-1] <= data_in[largest];
                    index_heapify <= largest + 1 ;
                    end
                    else begin
                        left <= 8'd0;
                        right <= 8'd0;
                        largest <= 8'd0;
                        index_heapify_1 <= index_heapify_1 - 1;
                    end
            end

            extract_max:begin
                busy <= 1'b1;
                if (extract) begin
                    if (index_1 >= 8'd0) begin
                        max <= data_in[0];
                        data_in[0] <= data_in[index_1-1];
                        data_in[index_1 - 1] <= 8'd0;
                        index_1 <= index_1 - 1;
                        index_heapify <= 8'd1;
                    end
                end
            end
            Max_heapify_1:begin
                left <= (2 * index_heapify)-1;
                right <= (2 * index_heapify);
            end
            Max_heapify_2: begin
                if (((index_1 - 1) >= left ) && ( data_in[left] > data_in[index_heapify-1])) begin
                    largest <= left;
                end
                else largest <= index_heapify - 1;

            end
            Max_heapify_3: begin
                if (((index_1 - 1) >= right  ) && (data_in[right] > data_in[largest])) begin
                    largest <= right;
                end
            end    
            Max_heapify_4:begin   
                if (largest != index_heapify -1 ) begin
                    data_in[largest] <= data_in[index_heapify-1];
                    data_in[index_heapify-1] <= data_in[largest];
                    index_heapify <= largest + 1 ;
                    end
                    else begin
                        left <= 8'd0;
                        right <= 8'd0;
                        largest <= 8'd0;
                        extract <= 1'b0;
                        busy <= 1'b0;
                    end
            end

            increase_val:begin
                if (increase_value < data_in[increase_index]) begin
                    increase <= 1'b0;
                    insert <= 1'b0;
                    busy <= 1'b0;
                    increase_index <= 8'd0;
                    parent <= 8'd0;
                end
                else begin
                    data_in[increase_index] <= increase_value;
                    busy <= 1'b1;
                end
            end
            increase_val_1:begin
                parent <= (increase_index!=8'd0)?(((increase_index-1) >> 1)):8'd0;
            end
            increase_val_2:begin
                if (increase_index > 8'd0 && ( data_in[parent] < data_in[increase_index])) begin
                    data_in[increase_index] <= data_in[parent];
                    data_in[parent] <= data_in[increase_index];
                    increase_index <= parent;
                end
                else begin
                    increase_index <= 8'd0;
                    parent <= 8'd0;
                    busy <=1'b0;
                    increase <= 1'b0;
                    insert <= 1'b0;
                end
            end
            insert_data: begin
                if (insert)begin
                    busy <= 1'b1;
                    index_1 <= index_1 + 1;
                end 
            end
            inser_data_1:begin
                data_in[index_1-1] <= 8'b0;
                increase_index <= index_1-1;
            end
            write: begin
                if (write_1) begin
                     busy <= 1'b1;
                     RAM_A <= index_2;
                     RAM_D <= data_in[index_2];
                     RAM_valid <= 1'b1;
                     busy <= 1'b1;
                     if (index_2 == index_1 ) begin
                        RAM_valid <= 1'b0;
                        busy <= 1'b0;
                        done <= 1'b1;
                        write_1 <= 1'b0;
                     end
                     else index_2 <= index_2 + 1;
                end                
            end
            finish: begin
                busy <= 1'b0;
                RAM_valid <= 1'b0;
                RAM_A <= 8'b0;
                RAM_D <= 8'b0;
                done <= 1'b0;
                build <= 1'b0;
                extract <= 1'b0;
                increase <= 1'b0;
                insert <= 1'b0;
                write_1 <= 1'b0;
                index_1 <= 8'b0;
                index_heapify <= 8'b0;
                largest <= 8'd0;
                left <= 8'b0;
                right <= 8'b0;
                index_2 <= 8'b0;
                max <= 8'b0;
                parent <= 8'b0;
                index_heapify_1 <=8'b0;
                increase_index <= 8'b0;
                increase_value <= 8'b0;
                for(i=0;i<255;i=i+1) begin
                    data_in[i] <= 8'b0;
                end
            end
        endcase
    end
end




always@(*)begin
    case(nowstate)
    Data_in:begin
    nextState = (data_valid==1'b1)? Data_in : Control;
    end
    Control: begin
        if (cmd==3'd0 && cmd_valid== 1'b1) begin
        nextState = build_queue ;
        end
        else if (cmd==3'd1 && cmd_valid== 1'b1) begin
        nextState = extract_max;
        end
        else if (cmd==3'd2 && cmd_valid== 1'b1) begin
        nextState = increase_val;
        end
        else if (cmd==3'd3 && cmd_valid== 1'b1) begin
        nextState = insert_data;
        end
        else if (cmd==3'd4 && cmd_valid== 1'b1) begin
        nextState = write;
        end
        else begin
        nextState = Control;
        end
    end
    build_queue: begin
    nextState = build_queue_1;
    end
    build_queue_1 : begin
    nextState = (index_heapify_1!= 8'd0)?Max_heapify1:Control;
    end
    Max_heapify1:begin
    nextState = Max_heapify2;
    end
    Max_heapify2:begin
    nextState = Max_heapify3;
    end
    Max_heapify3 :begin
    nextState = Max_heapify4;
    end
    Max_heapify4: begin
    nextState = (largest != (index_heapify-1))?Max_heapify1:build_queue_1;
    end
    extract_max:begin
    nextState = (extract==1'b1 && index_1 >= 8'd0)? Max_heapify_1 : extract_max;
    end
    Max_heapify_1 :begin
    nextState = Max_heapify_2;
    end
    Max_heapify_2: begin
    nextState = Max_heapify_3;
    end
    Max_heapify_3: begin
    nextState = Max_heapify_4;
    end
    Max_heapify_4 :begin
    nextState = (largest != (index_heapify-1))?Max_heapify_1:Control;
    end
    increase_val:begin
    nextState = (increase_value < data_in[increase_index])?Control:increase_val_1;
    end
    increase_val_1 : begin
    nextState = increase_val_2;
    end
    increase_val_2 : begin
    nextState = (increase_index > 8'd0 && ( data_in[parent] < data_in[increase_index]))?increase_val_1:Control;
    end
    insert_data:begin
    nextState = inser_data_1;
    end
    inser_data_1:begin
    nextState = increase_val;
    end
    write:begin
    nextState = ((write_1==1'b1)&&(index_2 == index_1))?finish:write;
    end
    finish:begin
    nextState = Data_in;
    end
    default:begin
    nextState = Data_in;
    end
    endcase
end

endmodule