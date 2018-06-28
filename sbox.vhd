library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity sbox is 
  port(input: in std_logic_vector(7 downto 0);
       output: out std_logic_vector(7 downto 0);
       ir_polynom: in std_logic_vector(8 downto 0);
       start,output_ack: in std_logic;
       input_ack,done: out std_logic;
       clk, reset: in std_logic);
end entity;

architecture shmoop of sbox is
	type FsmState is (rst,one,two);
	signal fsm_state : FsmState;
	signal inverse,prod,sum,inter: std_logic_vector(7 downto 0);
	signal t: std_logic_vector(0 to 0);
	signal inv_done,inv_start,inv_output_ack: std_logic;
begin
   process(fsm_state, start, output_ack, clk, reset, inv_done)
      variable next_state: FsmState;
      variable Tvar: std_logic_vector(0 to 0);
      variable ia_var,done_var,is_var,ioa_var: std_logic;
   begin
       -- defaults
       tvar := (others => '0');
       ia_var := '0'; done_var := '0'; is_var := '0'; ioa_var := '0';
       next_state := fsm_state;

       case fsm_state is 
          when rst =>
               if(start = '1') then
                  ia_var := '1'; is_var:='1';      
                  next_state := one;
	       else 
		  next_state := rst;
               end if;
	  when one =>
		if inv_done ='1' then
		  ioa_var:='1'; tvar(0):='1';
		  next_state:=two;
		else
		  next_state:=one;
		end if;
	  when two =>
		done_var:='1';
		if output_ack='1' then
		  next_state:=rst;
		else
		  next_state:=two;
		end if;
	end case;
	t<=tvar;
	input_ack<=ia_var; done<=done_var;
	inv_start<=is_var; inv_output_ack<=ioa_var;
     if(clk'event and (clk = '1')) then
	if(reset = '1') then
             fsm_state <= rst;
        else
             fsm_state <= next_state;
        end if;
     end if;

   end process;
	i0: inverter port map(a=>input,b=>inverse,ir_polynom=>ir_polynom,start=>inv_start,output_ack=>inv_output_ack,
			      done=>inv_done,clk=>clk,reset=>reset);
	prod(0) <= inverse(0) xor inverse(4) xor inverse(5) xor inverse(6) xor inverse(7);
	prod(1) <= inverse(0) xor inverse(1) xor inverse(5) xor inverse(6) xor inverse(7);
	prod(2) <= inverse(0) xor inverse(1) xor inverse(2) xor inverse(6) xor inverse(7);
	prod(3) <= inverse(0) xor inverse(1) xor inverse(2) xor inverse(3) xor inverse(7);
	prod(4) <= inverse(0) xor inverse(1) xor inverse(2) xor inverse(3) xor inverse(4);
	prod(5) <= inverse(1) xor inverse(2) xor inverse(3) xor inverse(4) xor inverse(5);
	prod(6) <= inverse(2) xor inverse(3) xor inverse(4) xor inverse(5) xor inverse(6);
	prod(7) <= inverse(3) xor inverse(4) xor inverse(5) xor inverse(6) xor inverse(7);

	sum <= prod xor "01100011";	

	result_reg: DataRegister generic map(data_width=>8) port map(Din=>sum , Dout=>output , Enable=>t(0) , clk=>clk);

end shmoop;
