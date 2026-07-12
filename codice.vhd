library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_start : in std_logic;
		i_add : in std_logic_vector(15 downto 0);
		
		o_done : out std_logic;
		
		o_mem_addr : out std_logic_vector(15 downto 0);
		i_mem_data : in std_logic_vector(7 downto 0);
		o_mem_data : out std_logic_vector(7 downto 0);
		o_mem_we : out std_logic;
		o_mem_en : out std_logic
	);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component data_path is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic;

           r1_load : in std_logic;
           r2_load : in std_logic;
           r3_load : in std_logic;
           r4_load : in std_logic;
           r5_load : in std_logic;
           r6_load : in std_logic;
           
           r1_sel : in std_logic_vector(1 downto 0);
           r2_sel : in std_logic;
           r3_sel : in std_logic;
           r4_sel : in std_logic;
           r5_sel : in std_logic;
           r6_sel : in std_logic;
           r7_sel : in std_logic;
           
           
           i_add : in std_logic_vector(15 downto 0);
           i_mem_data: in std_logic_vector(7 downto 0);
           o_mem_data: out std_logic_vector(7 downto 0);
           o_mem_addr : out std_logic_vector(15 downto 0);
           
           j : out std_logic_vector(15 downto 0); 
           i : in integer;
           m : in integer
           );
end component;

signal r1_load : std_logic;
signal r2_load : std_logic;
signal r3_load : std_logic;
signal r4_load : std_logic;
signal r5_load : std_logic;
signal r6_load : std_logic;
signal r1_sel : std_logic_vector(1 downto 0);
signal r2_sel : std_logic;
signal r3_sel : std_logic;
signal r4_sel : std_logic;
signal r5_sel : std_logic;
signal r6_sel : std_logic;
signal r7_sel : std_logic;
signal j : std_logic_vector(15 downto 0);   	--indice delle parole rimanenti
signal i : integer;		--indice del coefficiente analizzato
signal m : integer;		--sfasamento rispetto alla parola analizzata
type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12);
signal cur_state, next_state : S;

begin
    DATAPATH0: data_path port map(
       i_clk,
	   i_rst,
	   
	   r1_load,
	   r2_load,
	   r3_load,
	   r4_load,
	   r5_load,
	   r6_load,
	   
	   r1_sel,
	   r2_sel,
	   r3_sel,
	   r4_sel,
	   r5_sel,
	   r6_sel,
	   r7_sel,
	   
	   i_add,
	   i_mem_data,
	   o_mem_data,
	   o_mem_addr,
	   
	   j,
	   i,
	   m
	);
    
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            i <= 0;
            m <= -3;
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
            
            if cur_state = S1 then
                i <= 0;
            elsif cur_state = S3 and i < 2 then
                i <= i + 1;
            end if;
            
            if cur_state = S4 then
                i <= 0;
            elsif cur_state = S5 and i < 6 then
                i <= i + 1;
            end if;
            
            if cur_state = S7 then
            i <= 0;  -- reset counter when entering S5 next cycle
            m <= -3;
            elsif cur_state = S9 and m < 3 then
                m <= m + 1;
                i <= i + 1;
            end if;
            
        end if;
    end process;

    process(cur_state, i_start, i, m, j)    
    begin
    	next_state <= cur_state;
    	case cur_state is
    	
    		when S0 =>
    			if i_start = '1' then
    				next_state <= S1;
    			end if;
    			
    				
    		when S1 =>
    			next_state <= S2;
    		
    		when S2 => 
    			next_state <= S3;
    		
    		when S3 =>
    		    if i < 1 then
    		          next_state <= S2;
    		     else
    			     next_state <= S4;
    			 end if;
    		
    		when S4 =>
    			next_state <= S5;
    		
    		when S5 => 
    			if i < 6 then
    				next_state <= S5;
       			else 
    				next_state <= S6;
    			end if;
    		
    		when S6 =>
    			next_state <= S7;
    			
    		when S7 => 
    			 next_state <= S8;
    			    		
    		when S8 =>
    			next_state <= S9;
    			
    		when S9 => 
    			if m >= 3 then
    				next_state <= S10;
    			else
    				next_state <= S8;
    			end if;
    		
    		when S10 => 
    			next_state <= S11;
    		
    		when S11 => 
    		    if j = "0000000000000000" then
    			     next_state <= S12;
    			else
    			     next_state <= S7;
    			end if;
    	   
    	   when S12 =>
    	      if i_start = '0' then
                    next_state <= S0;
                end if;
    	   
    			
    	end case;
    end process;
    	
    process(cur_state, i)
    begin
    	r1_load <= '0';
    	r2_load <= '0';
    	r3_load <= '0';
    	r4_load <= '0';
    	r5_load <= '0';
    	r6_load <= '0';
    	r1_sel <= "00";
    	r2_sel <= '0';
    	r3_sel <= '0';
    	r4_sel <= '0';
    	r5_sel <= '0';
    	r6_sel <= '0';
    	r7_sel <= '0';
    	o_mem_en <= '0';
    	o_mem_we <= '0';
    	o_done <= '0';
    	
    	case cur_state is
    	    when S0 =>
              r1_load <= '1';
              --r2_sel <= '1';
    	      o_mem_en <= '1';

    		when S1 =>
    		  r1_load <= '1';
    		  r3_sel <= '1';
    		  r2_sel <= '1';
    		  o_mem_en <= '1';
    		
    		when S2 => 
				r1_load <= '1';
				r2_load <= '1';
				r3_load <= '1';
				r2_sel <= '0';
				r3_sel <= '1';
				o_mem_en <= '1';
			
			when S3 => 
				r1_load <= '1';
				r3_load <= '1';
				r2_sel <= '1';
				r3_sel <= '1';
				r4_sel <= '1';
				o_mem_en <= '1';
				
				if(i = 1) then
				    r1_sel <= "11";
				end if;
				
			when S4 => 
				r1_load <= '1';
			    r2_load <= '1'; 
				r3_load <= '1';
				r2_sel <= '1';
				r3_sel <= '1';
				o_mem_en <= '1';
				
								
			when S5 => 
				r1_load <= '1';
				r4_load <= '1';
				r2_sel <= '1';
				r3_sel <= '1';
				o_mem_en <= '1';
								
				
			when S6 => 
				r1_load <= '1';
				r1_sel <= "01";
				r2_sel <= '1';
                o_mem_en <= '1';
                				
			when S7 => 
				r1_load <= '1';
				r5_load <= '1';
				r1_sel <= "10";
				r2_sel <= '1';
				r3_sel <= '1';
				r6_sel <= '0'; 
				o_mem_en <= '1';
				
			
			when S8 => 
			     r2_sel <= '1';
				r3_sel <= '1';
			     r6_sel <= '1'; 
				o_mem_en <= '1';
				
			when S9 =>
			     r1_load <= '1';
				r5_load <= '1';
				r6_load <= '1';
				r2_sel <= '1';
				r3_sel <= '1';
				r6_sel <= '1';
				o_mem_en <= '1';
				
				
				
			when S10 => 
				r1_load <= '1';
				r2_load <= '1';
				r5_load <= '1';
				r6_load <= '1';
				r1_sel <= "10";
				r2_sel <= '1';
				r3_sel <= '1';
				r5_sel <= '1';
				r6_sel <= '1'; 

				r7_sel <= '1';
				--o_mem_we <= '1';
			
			when S11 => 
			    r5_load <= '1';
				r3_sel <= '1';
				r7_sel <= '1';
				
				o_mem_en <= '1';
				o_mem_we <= '1';

			
			when S12 => 
				o_done <= '1';
				
		end case;
	end process;
	
end Behavioral;	

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL; -- Consigliato



entity data_path is
    Port ( i_clk : in std_logic;
           i_rst : in std_logic;

           r1_load : in std_logic;
           r2_load : in std_logic;
           r3_load : in std_logic;
           r4_load : in std_logic;
           r5_load : in std_logic;
           r6_load : in std_logic;
           
           r1_sel : in std_logic_vector(1 downto 0);
           r2_sel : in std_logic;
           r3_sel : in std_logic;
           r4_sel : in std_logic;
           r5_sel : in std_logic;
           r6_sel : in std_logic;
           r7_sel : in std_logic;
           
           i_add : in std_logic_vector(15 downto 0);
           i_mem_data: in std_logic_vector(7 downto 0);
           o_mem_data: out std_logic_vector(7 downto 0);
           o_mem_addr: out std_logic_vector(15 downto 0);
           
           j : out std_logic_vector(15 downto 0); 
           i : in integer;
           m : in integer
           );
end data_path;

architecture Behavioral of data_path is
	signal o_reg1, mux2, mux4, mux3, mux5, mux7 :  std_logic_vector (15 downto 0);
	signal lsb_s : std_logic;
	type t_arrayC is array (0 to 6) of std_logic_vector(7 downto 0);
	type t_arrayK is array (1 to 2) of std_logic_vector(15 downto 0);
	signal arrayC : t_arrayC;
	signal o_reg2 : t_arrayK;
	signal  o_reg6: std_logic_vector(7 downto 0);
	signal mux1, o_reg3 : integer := 0;
	
	signal final, mult, o_reg5, mux6 : std_logic_vector(17 downto 0);
		
begin
	process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			o_reg1 <= "0000000000000000";
		elsif i_clk'event and i_clk = '1' then
			if(r1_load = '1') then
				o_reg1 <= mux2;
			end if;
		end if;
	end process;

	process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
		    o_reg2(1) <= "0000000000000000";
			o_reg2(2) <= "0000000000000000";
		elsif i_clk'event and i_clk = '1' then
			if(r2_load = '1') then
				o_reg2(2) <= mux5;
				if (r5_sel = '0') then
				    o_reg2(1) <= o_reg2(2);
				end if;
			end if;
		end if;
	end process;

	process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			o_reg3 <= 0;
		elsif i_clk'event and i_clk = '1' then
			if(r3_load = '1') then
				 if(i_mem_data(0) = '0') then
				    o_reg3 <= 0;
				 else 
				    o_reg3 <= 1;
				 end if;

			end if;
		end if;
	end process;

	process(i_clk, o_reg3, i_rst)
	begin
		if(i_rst = '1') then
		  --mult <= "0000000000000000";
		  for q in 0 to 6 loop
			arrayC(q) <= "00000000";
		  end loop;
		elsif i_clk'event and i_clk = '1' then
			if(r4_load = '1') then
				arrayC(i) <= i_mem_data;
			end if;
		end if;
		if(o_reg3 = 0) then
		  arrayC(0) <= "00000000";
		  arrayC(6) <= "00000000";
		end if;
	end process;

	process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			o_reg5 <= "000000000000000000";
		elsif i_clk'event and i_clk = '1' then
			if(r5_load = '1') then
			     if( o_reg1 >= i_add + 17 AND o_reg1 < i_add + o_reg2(1) + 17) then
				    o_reg5 <= mux6;
				 else
				    o_reg5 <= o_reg5 + "0000000000000000";
				 end if;
			end if;
		end if;
	end process;
	
	process(i_clk, i_rst)
	begin
			if(i_rst = '1') then
				o_reg6 <= "00000000";
				--final <= "0000000000000000";
			elsif i_clk'event and i_clk = '1' then
				if(r6_load = '1') then				
				    if(signed(final) < 0) then
				        if(o_reg3 = 0) then
                            if(signed(final) + 4 > -128) then
                               o_reg6 <= final(7 downto 0) + 4;
                            else
                               o_reg6 <= "10000000";
                            end if;
					     else
					       if(signed(final) + 2 > -128) then
                               o_reg6 <= final(7 downto 0) + 2;
                            else
                               o_reg6 <= "10000000";
					       end if;
					   end if;
					else 
					   if(signed(final) < 127) then
					       o_reg6 <= final(7 downto 0);
					    else
					       o_reg6 <= "01111111";
					    end if;
					 end if;
				end if;
			end if;
		end process;
		
	with r1_sel select
		mux1 <= 1 when "00",
				17 when "01",
				-3 when "10",
				to_integer(unsigned'("" & i_mem_data(0))) * 7 + 1 when "11",
				0 when others;
	
	with r2_sel select
		mux2 <=  std_logic_vector(mux1+unsigned(mux3)) when '1',
				 mux3 when '0',
				 "XXXXXXXXXXXXXXXX" when others;
	
	with r3_sel select
		mux3 <=  i_add when '0',
				 o_reg1 when '1',
				 "XXXXXXXXXXXXXXXX" when others;
	

	with r5_sel select
		mux5 <=  o_reg2(2) - "0000000000000001"  when '1',
				 o_reg2(2)(7 downto 0) & i_mem_data when '0',
				 "XXXXXXXXXXXXXXXX" when others;
				 
		with r6_sel select
		mux6 <=  mult + o_reg5  when '1',
				 "000000000000000000" when '0',
				 "XXXXXXXXXXXXXXXXXX" when others;		 
    
    with r7_sel select
		mux7 <=  o_reg1 when '0',
                 std_logic_vector(resize(unsigned(mux2) + unsigned(o_reg2(1)) - 1, 16)) when '1',
				 "XXXXXXXXXXXXXXXX" when others;
        
    mult <= std_logic_vector(resize(signed(arrayC(i)) * signed(i_mem_data), 18)) when (i >= 0) else "000000000000000000";
    
	final <=  std_logic_vector(shift_right(signed(o_reg5), 6))  +  std_logic_vector(shift_right(signed(o_reg5), 10)) when (o_reg3 = 1) 
		          else  std_logic_vector(shift_right(signed(o_reg5), 4)) + std_logic_vector(shift_right(signed(o_reg5), 6)) + std_logic_vector(shift_right(signed(o_reg5), 8)) +  std_logic_vector(shift_right(signed(o_reg5), 10));

    o_mem_data <= o_reg6;              
              
	o_mem_addr <= mux7;
	
	j <= "0000000000000000" when (o_reg2(2) = "0000000000000000") else o_reg2(2);

	
end Behavioral;
