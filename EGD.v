module EGD(
	input clk,
	input rst,
	input si_data,
	output reg valid,
	output reg [3:0] po_data,
	output reg busy
);

reg [2:0] x;
reg	[2:0] cs,ns;
reg [1:0] cnt;
reg [1:0] cnt_pro;
parameter idle = 2'b00;
parameter read = 2'b01;
parameter process = 2'b10;
parameter out = 2'b11;

always @(*) begin //busy
	if(rst)
		busy = 0;
	else if(ns == out)
		busy = 1;
	else if(ns == idle)
		busy = 1;
	else
		busy = 0;
end

always @(posedge clk or posedge rst) begin //valid
	if(rst)
		valid <= 0;
	else if(ns == out)
		valid <= 1;
	else
		valid <= 0;
end

always @(posedge clk or posedge rst) begin //cs
	if(rst)
		cs <= idle;
	else
		cs <= ns;	
end

always @(*) begin //ns
		case (cs)
			idle:begin
				if(cnt == 0 && !si_data)	
					ns = process;
				else
					ns = read;
			end
			read:begin
				if(cnt != 0 && !si_data)
					ns = process;
				else
					ns = read;
			end 
			process:begin
				if(cnt_pro == 0)
					ns = out;
				else 
					ns = process;
			end
			out:begin
				if(valid)
					ns = idle;
				else
					ns = out;
			end
		endcase
end

always @(posedge clk) begin //po_data
		if(ns == idle)
			po_data <= 4'd1;
		else if(ns == out)begin
			if(cnt != 0)
				po_data <= (po_data << cnt) + x - 1;
			else 	
				po_data <= 4'd0;
        end
        else
            po_data <= 1;
end

always @(posedge clk) begin //cnt_pro
	if(cs == process)
		cnt_pro <= cnt_pro - 1;
	else
		cnt_pro <= cnt;	
end

always @(posedge clk) begin //cnt	
		if(ns == read)begin
			if(si_data)
				cnt <= cnt + 1;
			else 
				cnt <= cnt;
		end
		else if(ns == process)
			cnt <= cnt;
		else if(ns == out)
			cnt <= cnt;
        else
            cnt <= 0;
end

always @(posedge clk or posedge rst) begin //x
	if(rst)
		x <= 0;
	else if (ns == process) begin
		x[0] <= si_data;
		x[1] <= x[0];
		x[2] <= x[1];
	end
	else if(ns == idle)
		x <= 0;
	else 
		x <= x;	
end

endmodule
	