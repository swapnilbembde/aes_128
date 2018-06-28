
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity inverterControlPath is 
	port (  T:out std_logic_vector(0 to 14);
		dvdr_start,dvdr_output_ack: out std_logic;
		S,dvdr_input_ack,dvdr_done: in std_logic;
		start,output_ack: in std_logic;
		input_ack,done : out std_logic;
		clk, reset: in std_logic
	     );
end entity;

architecture prost of inverterControlPath is 
   type FsmState is (rst, intermediate, divide, multiply, donestate);
   signal fsm_state : FsmState;
begin

   process(fsm_state, S, start, output_ack, clk, reset, dvdr_input_ack, dvdr_done)
      variable next_state: FsmState;
      variable Tvar: std_logic_vector(0 to 14);
      variable ia_var,done_var,ds_var,doa_var: std_logic;
   begin
       -- defaults
       Tvar := (others => '0');
       ia_var := '0'; done_var := '0'; ds_var := '0'; doa_var := '0';
       next_state := fsm_state;

       case fsm_state is 
          when rst =>
               if(start = '1') then
                  Tvar(0 to 3) := "1111"; ia_var := '1';             --newr:=a ; r:=ir_polynom ; t:=0 ; newt:=1 ;
                  next_state := intermediate;
	       else 
		  next_state := rst;
               end if;
	  when intermediate =>
	       if (S = '1') then
		  Tvar(14):='1';                                      --b:=t;
		  next_state := donestate;
	       else
		  next_state := divide;
		  Tvar(4 to 7) := "1111";                              --interr:=newr ; intert:=newt ; dvnd:=r ; dvsr:=newr;
	       end if;
	  when divide =>
	       if (dvdr_done = '0') then
		  ds_var := '1';
		  next_state := divide;
	       else
		  doa_var := '1';
                  Tvar(8 to 11) := "1111";                     --r:=interr ; newr:=r%newr ; dvnd:=(r/newr)*newt ; dvsr:=ir_polynom;
                  next_state := multiply;
	       end if;
	  when multiply =>
	       if (dvdr_done = '0') then
		  ds_var := '1';
		  next_state := multiply;
	       else
		  doa_var := '1';
                  Tvar(12 to 13) := "11";                     -- t:=intert ; newt:=t xor((r/newr)*newt mod (ir_polynom));
                  next_state := intermediate;
	       end if;
          when donestate =>
               done_var := '1';
	       if(output_ack = '1') then	
                  next_state := rst;
	       else
		  next_state := donestate;
	       end if; 
     end case;

     T <= Tvar;
     input_ack <= ia_var; done <= done_var; dvdr_start <= ds_var; dvdr_output_ack <= doa_var;
  
     if(clk'event and (clk = '1')) then
	if(reset = '1') then
             fsm_state <= rst;
        else
             fsm_state <= next_state;
        end if;
     end if;
   end process;
end prost;

