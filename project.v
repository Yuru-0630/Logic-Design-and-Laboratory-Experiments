module project(output reg [7:0] red, green, blue,     //LED燈
					output reg [6:0] t,                    //七段顯示器
					output reg [2:0] COMM, Life,				//LED; 剩餘次數
					output reg [1:0] COMM_CLK,					//七段顯示器
					output reg EN,
					output reg beep,								//被擊中的聲音
					input pose,mode,								//暫停鍵,模式
					input CLK, clear, Left, Right);
	reg [7:0] fall [7:0];										//掉落物和最後結果的顯示
	reg [7:0] people [7:0];										//玩家
	reg [6:0] seg1, seg2;
	reg [3:0] sec,minute;					
	reg [2:0] random01, random02, random03, r, r1, r2;	//r, r1, r2為掉落物的橫排位置
	integer a, b, c;												//掉落物的竪列位置
	reg left, right, temp;
	integer touch;													//被球碰到的次數

	
	segment7 S0(sec, A0,B0,C0,D0,E0,F0,G0);
	segment7 S1(minute, A1,B1,C1,D1,E1,F1,G1);
	divfreq div0(CLK, CLK_div);
	divfreq1 div1(CLK, CLK_time);
	divfreq2 div2(CLK, CLK_mv);
	integer line, count, count1;									//line為玩家的橫排位置

//------------------------------------------------------------------------------------------	
	
	//起始化各項值
	initial
		begin
			minute = 0;
			sec = 4'b0001;
			line = 3;
			random01 = (5*random01 + 3)%16;
			r = random01 % 8;
			random02 = (5*(random02+1) + 3)%16;
			r1 = random02 % 8;
			random03= (5*(random03+2) + 3)%16;
			r2 = random03 % 8;			
			a = 0;
			b = 0;
			c = 0;

			touch = 0;
			red = 8'b11111111;
			green = 8'b11111111;
			blue = 8'b11111111;
			fall[0] = 8'b11111111;
			fall[1] = 8'b11111111;
			fall[2] = 8'b11111111;
			fall[3] = 8'b11111111;
			fall[4] = 8'b11111111;
			fall[5] = 8'b11111111;
			fall[6] = 8'b11111111;
			fall[7] = 8'b11111111;
			people[0] = 8'b11111111;
			people[1] = 8'b11111111;
			people[2] = 8'b11111111;
			people[3] = 8'b00111111;
			people[4] = 8'b11111111;
			people[5] = 8'b11111111;
			people[6] = 8'b11111111;
			people[7] = 8'b11111111;
			count1 = 0;
			beep = 0;
		end

//---------------------------------------------------------------------------------------------------

	
//7段顯示器的視覺暫留
always@(posedge CLK_div)
	begin
		seg1[0] = A0;
		seg1[1] = B0;
		seg1[2] = C0;
		seg1[3] = D0;
		seg1[4] = E0;
		seg1[5] = F0;
		seg1[6] = G0;
		
		seg2[0] = A1;
		seg2[1] = B1;
		seg2[2] = C1;
		seg2[3] = D1;
		seg2[4] = E1;
		seg2[5] = F1;
		seg2[6] = G1;
		
		if(count1 == 0)
			begin
				t <= seg1;
				COMM_CLK[1] <= 1'b1;
				COMM_CLK[0] <= 1'b0;
				count1 <= 1'b1;
			end
			
			
		else if(count1 == 1)
			begin
				t <= seg2;
				COMM_CLK[1] <= 1'b0;
				COMM_CLK[0] <= 1'b1;
				count1 <= 1'b0;
			end
	end

//--------------------------------------------------------------------------------------------------------------------

//計時	
always@(posedge CLK_time, posedge clear)
	begin

	if(clear)
			begin
			
				if(mode == 1)
				begin
					minute = 4'b0011;
					sec = 4'b0;
				end
				
				if(mode == 0)
				begin
					minute = 4'b0000;
					sec = 4'b0001;
				end
			end
			
			
	else
		begin
		if(pose==0)								//沒按暫停
		begin
			if(touch < 3)				
				begin
					if(mode == 1)				//倒數30秒
					begin
						if(sec <= 0)
							begin
								sec <= 9;
								minute <= minute - 1;
							end
						else
							sec <= sec - 1;
						if(minute <= 0) minute <= 0;
					end
					
					else if(mode == 0)		//無限模式
					begin
						if(sec >= 9)
						begin
							sec <= 0;
							minute <= minute + 1;
						end
						else
							sec <= sec + 1;
					end
					
					
				end
			end
		end
			
	end

	
//-------------------------------------------------------------------------------------------------------

//LED的視覺暫留	
always@(posedge CLK_div)
	begin
		if(count >= 7)
			count <= 0;
		else
			count <= count + 1;
			
		COMM = count;
		EN = 1'b1;
		
		if(touch < 3)
			begin
				green <= fall[count];
				red <= people[count];
				blue <= people[count];
				
				
				if(touch == 0)
					Life <= 3'b111;
				else if(touch == 1)
					Life <= 3'b110;
				else if(touch == 2)
					Life <= 3'b100;
					
				if(minute <= 0 && sec <= 0)
				begin
					green <= fall[count];
				end
				
			end
			
			
			
		else
			begin
				if(minute <= 0 && sec <= 0)
					begin
						green <= fall[count];
					end
				else
				begin
					red <= fall[count];
					green <= 8'b11111111;
					Life <= 3'b000;
				end
			end
	end

//--------------------------------------------------------------------------------------------------------------

//遊戲内容
always@(posedge CLK_mv)
	begin
		beep = 0;
		right = Right;
		left = Left;	
		
		if(clear == 1)
			
				begin

					touch = 0;
					line = 3;
					a = 0;
					b = 0;
					c = 0;
					random01 = (5*random01 + 3)%16;
					r = random01 % 8;
					random02 = (5*(random02+1) + 3)%16;
					r1 = random02 % 8;
					random03= (5*(random03+2) + 3)%16;
					r2 = random03 % 8;
					fall[0] = 8'b11111111;
					fall[1] = 8'b11111111;
					fall[2] = 8'b11111111;
					fall[3] = 8'b11111111;
					fall[4] = 8'b11111111;
					fall[5] = 8'b11111111;
					fall[6] = 8'b11111111;
					fall[7] = 8'b11111111;
					people[0] = 8'b11111111;
					people[1] = 8'b11111111;
					people[2] = 8'b11111111;
					people[3] = 8'b11111111;
					people[4] = 8'b11111111;
					people[5] = 8'b11111111;
					people[6] = 8'b11111111;
					people[7] = 8'b11111111;
					
				end

//-------------------------------------------------------
if(pose == 0)
begin
		if(touch < 3)
			begin
		
			//掉落物1
				if(a == 0)
					begin
						fall[r][a] = 1'b0;
						a = a+1;
					end
				else if (a > 0 && a <= 7)
						begin
							fall[r][a-1] = 1'b1;
							fall[r][a] = 1'b0;
							a = a+1;
						end
				else if(a == 8) 
					begin
						fall[r][a-1] = 1'b1;
						random01 = (5*random01 + 3)%16;
						r = random01 % 8;
						a = 0;
					end
					
//----------------------------------------------------------
			//掉落物2
				if(b == 0)
					begin
						fall[r1][b] = 1'b0;
						b = b+1;
					end
				else if (b > 0 && b <= 7)
					begin
						fall[r1][b-1] = 1'b1;
						fall[r1][b] = 1'b0;
						b = b+1;
					end
				else if(b == 8) 
					begin
						fall[r1][b-1] = 1'b1;
						random02 = (5*(random01+1) + 3)%16;
						r1 = random02 % 8;
						b = 0;
					end
					
//------------------------------------------------------------

			//掉落物3
				if(c == 0)
					begin
						fall[r2][c] = 1'b0;
						c = c+1;
					end
				else if (c > 0 && c <= 7)
					begin
						fall[r2][c-1] = 1'b1;
						fall[r2][c] = 1'b0;
						c = c+1;
					end
				else if(c == 8) 
					begin
						fall[r2][c-1] = 1'b1;
						random03= (5*(random01+2) + 3)%16;
						r2 = random03 % 8;
						c = 0;
					end

//----------------------------------------------------------

			//人物的移動		
				if((right == 1) && (line != 7))
					begin
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line + 1;
					end
				if((left == 1) && (line != 0))
					begin
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line - 1;
					end
				people[line][6] = 1'b0;
				people[line][7] = 1'b0;

		
		
				if(fall[line][6] == 0)					//玩家高為2個點,這是上面的點碰到
					begin
						touch = touch + 1;
						fall[r][6] = 1'b1;						
						fall[r1][6] = 1'b1;
						fall[r2][6] = 1'b1;						
						a = 8;								
						b = 8;
						c = 8;
						
						beep = 1;
					end
				else if (fall[line][7] == 0)			//玩家高為2個點,這是下面的點碰到
					begin
						touch = touch + 1;												
						fall[r][7] = 1'b1;						
						fall[r1][7] = 1'b1;						
						fall[r2][7] = 1'b1;
						a = 8;
						b = 8;
						c = 8;
						beep=1;
					end


//----------------------------------------------------------------------

			//倒數時間結束,玩家win
				if(minute <= 0 && sec <= 0)
				begin

					fall[0] = 8'b11000011;
					fall[1] = 8'b10111101;
					fall[2] = 8'b01101010;
					fall[3] = 8'b01011110;
					fall[4] = 8'b01011110;
					fall[5] = 8'b01101010;
					fall[6] = 8'b10111101;
					fall[7] = 8'b11000011;
				end					
				
			end
		
//------------------------------------------------------------------------------			
			
		//else(被球碰到三次)
		else
			begin
			
				if(minute > 0 || sec > 0)			//時間結束,被碰到的次數自動變爲3,這是輸的情況
				begin
					fall[0] = 8'b11000011;
					fall[1] = 8'b10111101;
					fall[2] = 8'b01011010;
					fall[3] = 8'b01011110;
					fall[4] = 8'b01011110;
					fall[5] = 8'b01011010;
					fall[6] = 8'b10111101;
					fall[7] = 8'b11000011;
				end
				
				else if(minute <= 0 && sec <= 0)//時間結束,被碰到的次數自動變爲3,這是輸的情況
				begin
					fall[0] = 8'b11000011;
					fall[1] = 8'b10111101;
					fall[2] = 8'b01101010;
					fall[3] = 8'b01011110;
					fall[4] = 8'b01011110;
					fall[5] = 8'b01101010;
					fall[6] = 8'b10111101;
					fall[7] = 8'b11000011;
				end
			end
			

	end
end	
endmodule


//-------------------------------------------------------------------------------------------------

//秒數轉7段顯示器
module segment7(input [0:3] a, output A,B,C,D,E,F,G);
	
	assign A = ~(a[0]&~a[1]&~a[2] | ~a[0]&a[2] | ~a[1]&~a[2]&~a[3] | ~a[0]&a[1]&a[3]),
	       B = ~(~a[0]&~a[1] | ~a[1]&~a[2] | ~a[0]&~a[2]&~a[3] | ~a[0]&a[2]&a[3]),
			 C = ~(~a[0]&a[1] | ~a[1]&~a[2] | ~a[0]&a[3]),
			 D = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[2]&~a[3] | ~a[0]&a[1]&~a[2]&a[3] | ~a[1]&~a[2]&~a[3]),
			 E = ~(~a[1]&~a[2]&~a[3] | ~a[0]&a[2]&~a[3]),
			 F = ~(~a[0]&a[1]&~a[2] | ~a[0]&a[1]&~a[3] | a[0]&~a[1]&~a[2] | ~a[1]&~a[2]&~a[3]),
			 G = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[1]&~a[2] | ~a[0]&a[2]&~a[3]);
			 
endmodule


//--------------------------------------------------------------------------------------------------

//視覺暫留除頻器
module divfreq(input CLK, output reg CLK_div);
  reg [24:0] Count;
  always @(posedge CLK)
    begin
      if(Count > 5000)
        begin
          Count <= 25'b0;
          CLK_div <= ~CLK_div;
        end
      else
        Count <= Count + 1'b1;
    end
endmodule

//---------------------------------------------------------------------------------------------------

//計時除頻器
module divfreq1(input CLK, output reg CLK_time);
  reg [25:0] Count;
  initial
    begin
      CLK_time = 0;
	 end	
		
  always @(posedge CLK)
    begin
      if(Count > 25000000)
        begin
          Count <= 25'b0;
          CLK_time <= ~CLK_time;
        end
      else
        Count <= Count + 1'b1;
    end
endmodule 

//---------------------------------------------------------------------------------------------------

//掉落物&人物移動除頻器
module divfreq2(input CLK, output reg CLK_mv);
  reg [35:0] Count;
  initial
    begin
      CLK_mv = 0;
	 end	
		
  always @(posedge CLK)
    begin
      if(Count > 3000000)
        begin
          Count <= 35'b0;
          CLK_mv <= ~CLK_mv;
        end
      else
        Count <= Count + 1'b1;
    end
endmodule 