module switch_segment(clock_50m, pb, fnd_s, fnd_d);
	
	// input output.
	input clock_50m;
	input [15:0] pb;
	output reg [5:0] fnd_s;
	output reg [7:0] fnd_d;
	
	// clock.
	reg [15:0] npb;
	reg [31:0] init_counter;
	reg sw_clk;
	reg fnd_clk;
	reg [2:0] fnd_cnt;
	
	// 7-segment.
	reg [4:0] set_no1;
	reg [4:0] set_no2;
	reg [4:0] set_no3;
	reg [4:0] set_no4;
	reg [4:0] set_no5;
	reg [4:0] set_no6;
	reg [6:0] seg_100000;
	reg [6:0] seg_10000;
	reg [6:0] seg_1000;
	reg [6:0] seg_100;
	reg [6:0] seg_10;
	reg [6:0] seg_1;
	
	// pass check.
	
	
	
	
	// switch(keypad) control.
	reg [15:0] pb_1st;
	reg [15:0] pb_2nd;
	reg sw_toggle;
	
	// sw_status.
	reg [2:0] sw_status;
	reg [2:0] stack;
	reg sum = 0; //anything calculate =1, nothing = 0
	reg [20:0] num_temp; //calculate temp
	reg [21:0] cal_result;
	reg [1:0] on;
	
	parameter sw_error = 8;
	parameter sw_idle = 0;
	parameter sw_start = 1;
	parameter sw_s1 = 2;
	parameter sw_s2 = 3;
	parameter sw_s3 = 4;
	parameter sw_s4 = 5;
	parameter sw_s5 = 6;
	parameter sw_s6 = 7;
	
	 
	// parameter sw_save = 6;
	// parameter sw_cancel = 7;
	
	// initial.
	initial begin
		sw_status <= sw_idle;
		sw_toggle <= 0;
		npb <= 'h0000;
		pb_1st <= 'h0000;
		pb_2nd <= 'h0000;
		set_no1 <= 18;
		set_no2 <= 18;
		set_no3 <= 18;
		set_no4 <= 18;
		set_no5 <= 18;
		set_no6 <= 18;
		stack <= 0;
		num_temp <= 0;
		cal_result <= 0;
		on <= 0;
		
	end
	
	// input. clock divider.
	always begin
		npb <= ~pb;						// input
		sw_clk <= init_counter[20];		// clock for keypad(switch)
		fnd_clk <= init_counter[16];	// clock for 7-segment
	end
	
	// clock_50m. clock counter.
	always @(posedge clock_50m) begin
		init_counter <= init_counter + 1;
	end
	
	// sw_clk. get two consecutive inputs to correct switch(keypad) error.
	always @(posedge sw_clk) begin
		pb_2nd <= pb_1st;
		pb_1st <= npb;
		
		if (pb_2nd == 'h0000 && pb_1st != pb_2nd) begin
			sw_toggle <= 1;
		end
		
		if(on==1) begin
		
					if(cal_result >= 0 && cal_result < 10) begin
               set_no1 <= (cal_result % 10); 
               set_no2 <= 20;
               set_no3 <= 20;
               set_no4 <= 20;
               set_no5 <= 20;
               set_no6 <= 20;
               end
               else if(cal_result >= 10 && cal_result < 100) begin
               set_no1 <= (cal_result % 100) / 10;
               set_no2 <= (cal_result % 10);
               set_no3 <= 20;
               set_no4 <= 20;
               set_no5 <= 20; 
               set_no6 <= 20; 
               end
               else if(cal_result >= 100 && cal_result < 1000) begin
               set_no1 <= cal_result / 100;
               set_no2 <= (cal_result % 100) / 10;
               set_no3 <= (cal_result % 10);
               set_no4 <= 20; 
               set_no5 <= 20; 
               set_no6 <= 20; 
               end
               else if(cal_result >= 1000 && cal_result < 10000) begin
               set_no1 <= (cal_result % 10000) / 1000;
               set_no2 <= (cal_result % 1000) / 100;
               set_no3 <= (cal_result % 100) / 10; 
               set_no4 <= (cal_result % 10); 
               set_no5 <= 20; 
               set_no6 <= 20; 
               end
               else if(cal_result >= 10000 && cal_result < 100000) begin
               set_no1 <= (cal_result % 100000) / 10000;
               set_no2 <= (cal_result % 10000) / 1000;
               set_no3 <= (cal_result % 1000) / 100;  
               set_no4 <= (cal_result % 100) / 10;
               set_no5 <= (cal_result % 10); 
               set_no6 <=  20;
               end
               else if(cal_result >= 100000 && cal_result < 1000000) begin
               set_no1 <= cal_result / 100000; 
               set_no2 <= (cal_result % 100000) / 10000; 
               set_no3 <= (cal_result % 10000) / 1000; 
               set_no4 <= (cal_result % 1000) / 100; 
               set_no5 <= (cal_result % 100) / 10;
               set_no6 <= (cal_result % 10);
               end
         
               else if(cal_result > 999999) begin
                                         
                 set_no1 <= 0;//O
                 set_no2 <= 18;//null
                 set_no3 <= 16;//E
                 set_no4 <= 17;//r
                 set_no5 <= 17;//r
                 set_no6 <= 20;//null
               end
      end  
		
		if (sw_toggle == 1 && pb_1st == pb_2nd) begin
			sw_toggle <= 0;
			
			case (pb_1st)
			
				'h0001: begin  // switch_1
               case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 1;                    
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 1;                    
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 1;                    
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 1;                   
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 1;                 
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 1;
       
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0002: begin  // switch_2
               case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 2;
                    
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 2;
                     
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 2;
                   
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 2;
                    
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 2;
                   
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 2;
                  
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0004: begin  // switch_3
               case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 3;
                    
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 3;
                    
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 3;
                   
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 3;
                   
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 3;
                  
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 3;
                
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0008: begin  //+++++++++++++++++++++++++++++++++++++++++++++
					
					
					case (sw_status)
						sw_idle: begin
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;   							
						end
						
						sw_start: begin //++ -> ^2
							sw_status <= sw_s1;
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;							
						end
						
						sw_s1: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= set_no1;		
							stack<=1;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + set_no1;
								2 : num_temp<= num_temp - set_no1;
								3 : num_temp<= num_temp * set_no1;
								4 : num_temp<= num_temp / set_no1;
								5 : num_temp<= num_temp % set_no1;
								endcase							
							stack<=1;
							end														
						end
						
						sw_s2: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10*set_no1 + set_no2;		
							stack<=1;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10*set_no1 + set_no2);
								2 : num_temp<= num_temp - (10*set_no1 + set_no2);
								3 : num_temp<= num_temp * (10*set_no1 + set_no2);
								4 : num_temp<= num_temp / (10*set_no1 + set_no2);
								5 : num_temp<= num_temp % (10*set_no1 + set_no2);
								endcase							
							stack<=1;
							end														
						end
						
					   sw_s3: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							
							stack<=1;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100*set_no1 + 10*set_no2 + set_no3);
								2 : num_temp<= num_temp - (100*set_no1 + 10*set_no2 + set_no3);
								3 : num_temp<= num_temp * (100*set_no1 + 10*set_no2 + set_no3);
								4 : num_temp<= num_temp / (100*set_no1 + 10*set_no2 + set_no3);
								5 : num_temp<= num_temp % (100*set_no1 + 10*set_no2 + set_no3);
								endcase							
							stack<=1;
							end														
						end
						
						sw_s4: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4;		
							stack<=1;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								2 : num_temp<= num_temp - (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								3 : num_temp<= num_temp * (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								4 : num_temp<= num_temp / (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								5 : num_temp<= num_temp % (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								endcase							
							stack<=1;
							end	
						end
						
						sw_s5: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5;		
							stack<=1;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								2 : num_temp<= num_temp - (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								3 : num_temp<= num_temp * (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								4 : num_temp<= num_temp / (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								5 : num_temp<= num_temp % (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								endcase							
							stack<=1;
							end	
						end
						
						sw_s6: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6;		
							stack<=1;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								2 : num_temp<= num_temp - (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								3 : num_temp<= num_temp * (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								4 : num_temp<= num_temp / (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								5 : num_temp<= num_temp % (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								endcase							
							stack<=1;
							end	
						end						
					endcase
					begin
							set_no1 <= 18;
                     set_no2 <= 18;
                     set_no3 <= 18;
                     set_no4 <= 18;
                     set_no5 <= 18;
                     set_no6 <= 18; 
						end
				end
				
				'h0010: begin  // switch_4
               case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 4;
                    
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 4;
                  
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 4;
                   
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 4;
                     
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 4;
                     
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 4;
                  
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0020: begin
					 case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 5;
                  
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 5;
                   
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 5;
                   
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 5;
                  
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 5;
                
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 5;
                   
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0040: begin
					 case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 6;
                    
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 6;
                  
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 6;
                  
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 6;
                   
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 6;
              
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 6;
              
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0080: begin //--------------------------------------------------
					case (sw_status)
						sw_idle: begin
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;   							
						end
						
						sw_start: begin //
							sw_status <= sw_s1;
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;							
						end
						
						sw_s1: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= set_no1;		
							stack<=2;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + set_no1;
								2 : num_temp<= num_temp - set_no1;
								3 : num_temp<= num_temp * set_no1;
								4 : num_temp<= num_temp / set_no1;
								5 : num_temp<= num_temp % set_no1;
								endcase							
							stack<=2;
							end														
						end
						
						sw_s2: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10*set_no1 + set_no2;		
							stack<=2;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10*set_no1 + set_no2);
								2 : num_temp<= num_temp - (10*set_no1 + set_no2);
								3 : num_temp<= num_temp * (10*set_no1 + set_no2);
								4 : num_temp<= num_temp / (10*set_no1 + set_no2);
								5 : num_temp<= num_temp % (10*set_no1 + set_no2);
								endcase							
							stack<=2;
							end														
						end
						
					   sw_s3: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100*set_no1 + 10*set_no2 + set_no3;	
							stack<=2;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100*set_no1 + 10*set_no2 + set_no3);
								2 : num_temp<= num_temp - (100*set_no1 + 10*set_no2 + set_no3);
								3 : num_temp<= num_temp * (100*set_no1 + 10*set_no2 + set_no3);
								4 : num_temp<= num_temp / (100*set_no1 + 10*set_no2 + set_no3);
								5 : num_temp<= num_temp % (100*set_no1 + 10*set_no2 + set_no3);
								endcase							
							stack<=2;
							end														
						end
						
						sw_s4: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4;		
							stack<=2;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								2 : num_temp<= num_temp - (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								3 : num_temp<= num_temp * (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								4 : num_temp<= num_temp / (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								5 : num_temp<= num_temp % (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								endcase							
							stack<=2;
							end	
						end
						
						sw_s5: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5;		
							stack<=2;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								2 : num_temp<= num_temp - (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								3 : num_temp<= num_temp * (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								4 : num_temp<= num_temp / (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								5 : num_temp<= num_temp % (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								endcase							
							stack<=2;
							end	
						end
						
						sw_s6: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6;		
							stack<=2;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								2 : num_temp<= num_temp - (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								3 : num_temp<= num_temp * (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								4 : num_temp<= num_temp / (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								5 : num_temp<= num_temp % (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								endcase							
							stack<=2;
							end	
						end						
					endcase
					begin
							set_no1 <= 18;
                     set_no2 <= 18;
                     set_no3 <= 18;
                     set_no4 <= 18;
                     set_no5 <= 18;
                     set_no6 <= 18; 
						end
				end
				
				'h0100: begin
					 case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 7;
                    
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 7;
                   
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 7;
                
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 7;
                  
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 7;
                  
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 7;
                  
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0200: begin
					 case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 8;
                    
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 8;
                  
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 8;
                   
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 8;
                  
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 8;
                 
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 8;
                    
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0400: begin
					 case (sw_status)
                  sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 9;
                     
                  end
						
                  sw_s1: begin
                     sw_status <= sw_s2;
                     set_no2 <= 9;
                   
                  end
                  sw_s2: begin
                     sw_status <= sw_s3;
                     set_no3 <= 9;
                
                  end
                  sw_s3: begin
                     sw_status <= sw_s4;
                     set_no4 <= 9;
                   
                  end
                  sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 9;
                
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 9;
                
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h0800: begin //*******************************************************
					case (sw_status)
						sw_idle: begin
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;   							
						end
						
						sw_start: begin //
							sw_status <= sw_s1;
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;							
						end
						
						sw_s1: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= set_no1;		
							stack<=3;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + set_no1;
								2 : num_temp<= num_temp - set_no1;
								3 : num_temp<= num_temp * set_no1;
								4 : num_temp<= num_temp / set_no1;
								5 : num_temp<= num_temp % set_no1;
								endcase							
							stack<=2;
							end														
						end
						
						sw_s2: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10*set_no1 + set_no2;		
							stack<=3;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10*set_no1 + set_no2);
								2 : num_temp<= num_temp - (10*set_no1 + set_no2);
								3 : num_temp<= num_temp * (10*set_no1 + set_no2);
								4 : num_temp<= num_temp / (10*set_no1 + set_no2);
								5 : num_temp<= num_temp % (10*set_no1 + set_no2);
								endcase							
							stack<=3;
							end														
						end
						
					   sw_s3: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100*set_no1 + 10*set_no2 + set_no3;	
							stack<=3;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100*set_no1 + 10*set_no2 + set_no3);
								2 : num_temp<= num_temp - (100*set_no1 + 10*set_no2 + set_no3);
								3 : num_temp<= num_temp * (100*set_no1 + 10*set_no2 + set_no3);
								4 : num_temp<= num_temp / (100*set_no1 + 10*set_no2 + set_no3);
								5 : num_temp<= num_temp % (100*set_no1 + 10*set_no2 + set_no3);
								endcase							
							stack<=3;
							end														
						end
						
						sw_s4: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4;		
							stack<=3;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								2 : num_temp<= num_temp - (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								3 : num_temp<= num_temp * (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								4 : num_temp<= num_temp / (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								5 : num_temp<= num_temp % (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								endcase							
							stack<=3;
							end	
						end
						
						sw_s5: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5;		
							stack<=3;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								2 : num_temp<= num_temp - (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								3 : num_temp<= num_temp * (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								4 : num_temp<= num_temp / (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								5 : num_temp<= num_temp % (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								endcase							
							stack<=3;
							end	
						end
						
						sw_s6: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6;		
							stack<=3;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								2 : num_temp<= num_temp - (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								3 : num_temp<= num_temp * (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								4 : num_temp<= num_temp / (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								5 : num_temp<= num_temp % (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								endcase							
							stack<=3;
							end	
						end						
					endcase
					begin
							set_no1 <= 18;
                     set_no2 <= 18;
                     set_no3 <= 18;
                     set_no4 <= 18;
                     set_no5 <= 18;
                     set_no6 <= 18; 
						end
				end
				
				'h1000: begin	// enter
					on=1;
					case (sw_status)
						sw_idle: begin
							sw_status <= sw_start;
							set_no1 <= 18;
							set_no2 <= 18;
							set_no3 <= 18;
							set_no4 <= 18;
							set_no5 <= 18;
							set_no6 <= 18;
							cal_result <= 0;
							num_temp <= 0;
							on <=0;
						end
						
						sw_s1 : begin
							case(stack)
								1 : begin
								num_temp = num_temp + set_no1;
								cal_result = num_temp;								
								sw_status = sw_idle;
								end								
								2: begin
								num_temp = num_temp - set_no1;
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								3: begin
								num_temp = num_temp * set_no1;
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								4: begin
								num_temp = num_temp / set_no1;
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								5: begin
								num_temp = num_temp % set_no1;
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
							endcase;		
						end
						
						sw_s2 : begin
							case(stack)
								1 : begin
								num_temp = num_temp + (10*set_no1 + set_no2);
								cal_result = num_temp;								
								sw_status = sw_idle;
								end								
								2: begin
								num_temp = num_temp - (10*set_no1 + set_no2);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								3: begin
								num_temp = num_temp * (10*set_no1 + set_no2);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								4: begin
								num_temp = num_temp / (10*set_no1 + set_no2);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								5: begin
								num_temp = num_temp % (10*set_no1 + set_no2);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
							endcase;		
						end
						
						
						
						
						sw_s3 : begin
							case(stack)
								1 : begin
								num_temp = num_temp + (100*set_no1 + 10*set_no2 + set_no3);
								cal_result = num_temp;								
								sw_status = sw_idle;
								end								
								2: begin
								num_temp = num_temp - (100*set_no1 + 10*set_no2 + set_no3);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								3: begin
								num_temp = num_temp * (100*set_no1 + 10*set_no2 + set_no3);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								4: begin
								num_temp = num_temp / (100*set_no1 + 10*set_no2 + set_no3);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								5: begin
								num_temp = num_temp % (100*set_no1 + 10*set_no2 + set_no3);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
							endcase;		
						end
						
						
						sw_s4 : begin
							case(stack)
								1 : begin
								num_temp = num_temp + (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								cal_result = num_temp;								
								sw_status = sw_idle;
								end								
								2: begin
								num_temp = num_temp - (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								3: begin
								num_temp = num_temp * (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								4: begin
								num_temp = num_temp / (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								5: begin
								num_temp = num_temp % (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
							endcase;		
						end
						
						
						
						
						sw_s5 : begin
							case(stack)
								1 : begin
								num_temp = num_temp + (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								cal_result = num_temp;								
								sw_status = sw_idle;
								end								
								2: begin
								num_temp = num_temp - (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								3: begin
								num_temp = num_temp * (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								4: begin
								num_temp = num_temp / (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								5: begin
								num_temp = num_temp % (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
							endcase;		
						end
						
						
						
						sw_s6 : begin
							case(stack)
								1 : begin
								num_temp = num_temp + (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								cal_result = num_temp;								
								sw_status = sw_idle;
								end								
								2: begin
								num_temp = num_temp - (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								3: begin
								num_temp = num_temp * (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								4: begin
								num_temp = num_temp / (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
								5: begin
								num_temp = num_temp % (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								cal_result = num_temp;									
								sw_status = sw_idle;
								end								
							endcase;		
						end					
						
						
						
						default: begin
							sw_status <= sw_idle;
							set_no1 <= 16;
							set_no2 <= 17;
							set_no3 <= 17;
							set_no4 <= 20;
							set_no5 <= 18;
							set_no6 <= 18;
							
						end
					endcase
				end
				
				'h2000: begin //0
					case (sw_status)
						sw_idle: begin
                     set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;                     
                  end
						
                  sw_start: begin
                     sw_status <= sw_s1;
                     set_no1 <= 0;
                     
                  end
						
						sw_s1: begin
							sw_status <= sw_s2;
							set_no2 <= 0;
						
						end
						sw_s2: begin
							sw_status <= sw_s3;
							set_no3 <= 0;
						
						end
						sw_s3: begin
							sw_status <= sw_s4;
							set_no4 <= 0;							
						end
						
						sw_s4: begin
                     sw_status <= sw_s5;
                     set_no5 <= 0;
               
                  end
                  sw_s5: begin
                     sw_status <= sw_s6;
                     set_no6 <= 0;
            
                  end
                  sw_s6: begin
                     sw_status <= sw_idle;
                     set_no1 <= 20;   
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;
							num_temp <= 0;
                     
                  end
               endcase
            end
				
				'h4000: begin //%rest%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					case (sw_status)
						sw_idle: begin
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;   							
						end
						
						sw_start: begin //
							sw_status <= sw_s1;
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;							
						end
						
						sw_s1: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= set_no1;		
							stack<=5;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + set_no1;
								2 : num_temp<= num_temp - set_no1;
								3 : num_temp<= num_temp * set_no1;
								4 : num_temp<= num_temp / set_no1;
								5 : num_temp<= num_temp % set_no1;
								endcase							
							stack<=5;
							end														
						end
						
						sw_s2: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10*set_no1 + set_no2;		
							stack<=5;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10*set_no1 + set_no2);
								2 : num_temp<= num_temp - (10*set_no1 + set_no2);
								3 : num_temp<= num_temp * (10*set_no1 + set_no2);
								4 : num_temp<= num_temp / (10*set_no1 + set_no2);
								5 : num_temp<= num_temp % (10*set_no1 + set_no2);
								endcase							
							stack<=5;
							end														
						end
						
					   sw_s3: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100*set_no1 + 10*set_no2 + set_no3;	
							stack<=5;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100*set_no1 + 10*set_no2 + set_no3);
								2 : num_temp<= num_temp - (100*set_no1 + 10*set_no2 + set_no3);
								3 : num_temp<= num_temp * (100*set_no1 + 10*set_no2 + set_no3);
								4 : num_temp<= num_temp / (100*set_no1 + 10*set_no2 + set_no3);
								5 : num_temp<= num_temp % (100*set_no1 + 10*set_no2 + set_no3);
								endcase							
							stack<=5;
							end														
						end
						
						sw_s4: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4;		
							stack<=5;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								2 : num_temp<= num_temp - (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								3 : num_temp<= num_temp * (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								4 : num_temp<= num_temp / (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								5 : num_temp<= num_temp % (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								endcase							
							stack<=5;
							end	
						end
						
						sw_s5: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5;		
							stack<=5;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								2 : num_temp<= num_temp - (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								3 : num_temp<= num_temp * (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								4 : num_temp<= num_temp / (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								5 : num_temp<= num_temp % (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								endcase							
							stack<=5;
							end	
						end
						
						sw_s6: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6;		
							stack<=5;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								2 : num_temp<= num_temp - (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								3 : num_temp<= num_temp * (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								4 : num_temp<= num_temp / (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								5 : num_temp<= num_temp % (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								endcase							
							stack<=5;
							end	
						end						
					endcase
					begin
							set_no1 <= 18;
                     set_no2 <= 18;
                     set_no3 <= 18;
                     set_no4 <= 18;
                     set_no5 <= 18;
                     set_no6 <= 18; 
						end
				end
				'h8000: begin // divide//////////////////////////////////////
					case (sw_status)
						sw_idle: begin
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;   							
						end
						
						sw_start: begin //
							sw_status <= sw_s1;
							set_no1 <= 20;
                     set_no2 <= 20;
                     set_no3 <= 16;
                     set_no4 <= 17;
                     set_no5 <= 17;
                     set_no6 <= 20;							
						end
						
						sw_s1: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= set_no1;		
							stack<=4;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + set_no1;
								2 : num_temp<= num_temp - set_no1;
								3 : num_temp<= num_temp * set_no1;
								4 : num_temp<= num_temp / set_no1;
								5 : num_temp<= num_temp % set_no1;
								endcase							
							stack<=4;
							end														
						end
						
						sw_s2: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10*set_no1 + set_no2;		
							stack<=4;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10*set_no1 + set_no2);
								2 : num_temp<= num_temp - (10*set_no1 + set_no2);
								3 : num_temp<= num_temp * (10*set_no1 + set_no2);
								4 : num_temp<= num_temp / (10*set_no1 + set_no2);
								5 : num_temp<= num_temp % (10*set_no1 + set_no2);
								endcase							
							stack<=4;
							end														
						end
						
					   sw_s3: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100*set_no1 + 10*set_no2 + set_no3;	
							stack<=4;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100*set_no1 + 10*set_no2 + set_no3);
								2 : num_temp<= num_temp - (100*set_no1 + 10*set_no2 + set_no3);
								3 : num_temp<= num_temp * (100*set_no1 + 10*set_no2 + set_no3);
								4 : num_temp<= num_temp / (100*set_no1 + 10*set_no2 + set_no3);
								5 : num_temp<= num_temp % (100*set_no1 + 10*set_no2 + set_no3);
								endcase							
							stack<=4;
							end														
						end
						
						sw_s4: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4;		
							stack<=4;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								2 : num_temp<= num_temp - (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								3 : num_temp<= num_temp * (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								4 : num_temp<= num_temp / (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								5 : num_temp<= num_temp % (1000*set_no1 + 100*set_no2 + 10*set_no3 + set_no4);
								endcase							
							stack<=4;
							end	
						end
						
						sw_s5: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5;		
							stack<=4;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								2 : num_temp<= num_temp - (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								3 : num_temp<= num_temp * (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								4 : num_temp<= num_temp / (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								5 : num_temp<= num_temp % (10000*set_no1 + 1000*set_no2 + 100*set_no3 + 10*set_no4 + set_no5);
								endcase							
							stack<=4;
							end	
						end
						
						sw_s6: begin //of 1
							sw_status <= sw_start; //sw_start or sw_idle							
							if(sum==0) begin //nothing sum
							num_temp<= 100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6;		
							stack<=4;
							sum<=1;
							end								
							else if(sum==1) begin
								case(stack)
								1 : num_temp<= num_temp + (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								2 : num_temp<= num_temp - (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								3 : num_temp<= num_temp * (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								4 : num_temp<= num_temp / (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								5 : num_temp<= num_temp % (100000*set_no1 + 10000*set_no2 + 1000*set_no3 + 100*set_no4 + 10*set_no5 + set_no6);
								endcase							
							stack<=4;
							end	
						end						
					endcase
					begin
							set_no1 <= 18;
                     set_no2 <= 18;
                     set_no3 <= 18;
                     set_no4 <= 18;
                     set_no5 <= 18;
                     set_no6 <= 18; 
						end
				end
			endcase
		end
	end
	
	// 7-segment.
	always @(set_no1) begin
		case (set_no1)
			0: seg_100000 <= 'b0011_1111;
			1: seg_100000 <= 'b0000_0110;
			2: seg_100000 <= 'b0101_1011;
			3: seg_100000 <= 'b0100_1111;
			4: seg_100000 <= 'b0110_0110;
			5: seg_100000 <= 'b0110_1101;
			6: seg_100000 <= 'b0111_1101;
			7: seg_100000 <= 'b0000_0111;
			8: seg_100000 <= 'b0111_1111;
			9: seg_100000 <= 'b0110_0111;
			10: seg_100000 <= 'b0111_1000;
			11: seg_100000 <= 'b0111_0011;
			12: seg_100000 <= 'b0111_0111;
			13: seg_100000 <= 'b0111_1100;
			14: seg_100000 <= 'b0011_1001;
			15: seg_100000 <= 'b0101_1110;
			16: seg_100000 <= 'b0111_1001;
			17: seg_100000 <= 'b0101_0000;
			18: seg_100000 <= 'b0100_0000;
			19: seg_100000 <= 'b0101_0100;
			default: seg_100000 <= 'b0000_0000;
		endcase
	end
	always @(set_no2) begin
		case (set_no2)
			0: seg_10000 <= 'b0011_1111;
			1: seg_10000 <= 'b0000_0110;
			2: seg_10000 <= 'b0101_1011;
			3: seg_10000 <= 'b0100_1111;
			4: seg_10000 <= 'b0110_0110;
			5: seg_10000 <= 'b0110_1101;
			6: seg_10000 <= 'b0111_1101;
			7: seg_10000 <= 'b0000_0111;
			8: seg_10000 <= 'b0111_1111;
			9: seg_10000 <= 'b0110_0111;
			10: seg_10000 <= 'b0111_1000;
			11: seg_10000 <= 'b0111_0011;
			12: seg_10000 <= 'b0111_0111;
			13: seg_10000 <= 'b0111_1100;
			14: seg_10000 <= 'b0011_1001;
			15: seg_10000 <= 'b0101_1110;
			16: seg_10000 <= 'b0111_1001;
			17: seg_10000 <= 'b0101_0000;
			18: seg_10000 <= 'b0100_0000;
			19: seg_10000 <= 'b0101_0100;
			default: seg_10000 <= 'b0000_0000;
		endcase
	end
	always @(set_no3) begin
		case (set_no3)
			0: seg_1000 <= 'b0011_1111;
			1: seg_1000 <= 'b0000_0110;
			2: seg_1000 <= 'b0101_1011;
			3: seg_1000 <= 'b0100_1111;
			4: seg_1000 <= 'b0110_0110;
			5: seg_1000 <= 'b0110_1101;
			6: seg_1000 <= 'b0111_1101;
			7: seg_1000 <= 'b0000_0111;
			8: seg_1000 <= 'b0111_1111;
			9: seg_1000 <= 'b0110_0111;
			10: seg_1000 <= 'b0111_1000;
			11: seg_1000 <= 'b0111_0011;
			12: seg_1000 <= 'b0111_0111;
			13: seg_1000 <= 'b0111_1100;
			14: seg_1000 <= 'b0011_1001;
			15: seg_1000 <= 'b0101_1110;
			16: seg_1000 <= 'b0111_1001;
			17: seg_1000 <= 'b0101_0000;
			18: seg_1000 <= 'b0100_0000;
			19: seg_1000 <= 'b0101_0100;
			default: seg_1000 <= 'b0000_0000;
		endcase
	end
	always @(set_no4) begin
		case (set_no4)
			0: seg_100 <= 'b0011_1111;
			1: seg_100 <= 'b0000_0110;
			2: seg_100 <= 'b0101_1011;
			3: seg_100 <= 'b0100_1111;
			4: seg_100 <= 'b0110_0110;
			5: seg_100 <= 'b0110_1101;
			6: seg_100 <= 'b0111_1101;
			7: seg_100 <= 'b0000_0111;
			8: seg_100 <= 'b0111_1111;
			9: seg_100 <= 'b0110_0111;
			10: seg_100 <= 'b0111_1000;
			11: seg_100 <= 'b0111_0011;
			12: seg_100 <= 'b0111_0111;
			13: seg_100 <= 'b0111_1100;
			14: seg_100 <= 'b0011_1001;
			15: seg_100 <= 'b0101_1110;
			16: seg_100 <= 'b0111_1001;
			17: seg_100 <= 'b0101_0000;
			18: seg_100 <= 'b0100_0000;
			19: seg_100 <= 'b0101_0100;
			default: seg_100 <= 'b0000_0000;
		endcase
	end
	
	always @(set_no5) begin
		case (set_no5)
			0: seg_10 <= 'b0011_1111;
			1: seg_10 <= 'b0000_0110;
			2: seg_10 <= 'b0101_1011;
			3: seg_10 <= 'b0100_1111;
			4: seg_10 <= 'b0110_0110;
			5: seg_10 <= 'b0110_1101;
			6: seg_10 <= 'b0111_1101;
			7: seg_10 <= 'b0000_0111;
			8: seg_10 <= 'b0111_1111;
			9: seg_10 <= 'b0110_0111;
			10: seg_10 <= 'b0111_1000;
			11: seg_10 <= 'b0111_0011;
			12: seg_10 <= 'b0111_0111;
			13: seg_10 <= 'b0111_1100;
			14: seg_10 <= 'b0011_1001;
			15: seg_10 <= 'b0101_1110;
			16: seg_10 <= 'b0111_1001;
			17: seg_10 <= 'b0101_0000;
			18: seg_10 <= 'b0100_0000;
			19: seg_10 <= 'b0101_0100;
			default: seg_10 <= 'b0000_0000;
		endcase
	end
	
	always @(set_no6) begin
		case (set_no6)
			0: seg_1 <= 'b0011_1111;
			1: seg_1 <= 'b0000_0110;
			2: seg_1 <= 'b0101_1011;
			3: seg_1 <= 'b0100_1111;
			4: seg_1 <= 'b0110_0110;
			5: seg_1 <= 'b0110_1101;
			6: seg_1 <= 'b0111_1101;
			7: seg_1 <= 'b0000_0111;
			8: seg_1 <= 'b0111_1111;
			9: seg_1 <= 'b0110_0111;
			10: seg_1 <= 'b0011_1110;
			11: seg_1 <= 'b0111_0011;
			12: seg_1 <= 'b0111_0111;
			13: seg_1 <= 'b0111_1100;
			14: seg_1 <= 'b0011_1001;
			15: seg_1 <= 'b0101_1110;
			16: seg_1 <= 'b0111_1001;
			17: seg_1 <= 'b0101_0000;
			18: seg_1 <= 'b0100_0000;
			19: seg_1 <= 'b0101_0100;
			default: seg_1 <= 'b0000_0000;
		endcase
	end
	
	// fnd_clk. output.
	always @(posedge fnd_clk) begin
		fnd_cnt <= fnd_cnt + 1;
		case (fnd_cnt)
			5: begin
				fnd_d <= seg_100000;
				fnd_s <= 'b011111;
			end
			4: begin
				fnd_d <= seg_10000;
				fnd_s <= 'b101111;
			end	
			3: begin
				fnd_d <= seg_1000;
				fnd_s <= 'b110111;
			end
			2: begin
				fnd_d <= seg_100;
				fnd_s <= 'b111011;
			end
			1: begin
				fnd_d <= seg_10;
				fnd_s <= 'b111101;
			end
			0: begin
				fnd_d <= seg_1;
				fnd_s <= 'b111110;
			end
		endcase
	end
	
endmodule
