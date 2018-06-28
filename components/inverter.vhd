library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity inverter is 
  port(a: in std_logic_vector(7 downto 0);
       b: out std_logic_vector(7 downto 0);
       ir_polynom: in std_logic_vector(8 downto 0);
       start,output_ack: in std_logic;
       input_ack,done: out std_logic;
       clk, reset: in std_logic);
end entity;

architecture prost of inverter is
   signal S,dvdr_start,dvdr_output_ack,dvdr_input_ack,dvdr_done: std_logic;
   signal T: std_logic_vector(0 to 14);
begin

    CP: inverterControlPath 
	     port map(T => T,
			S => S,
			dvdr_start => dvdr_start,
			dvdr_output_ack => dvdr_output_ack,
			dvdr_input_ack => dvdr_input_ack,
			dvdr_done => dvdr_done,
			start => start,
			input_ack => input_ack,
			done => done,
			output_ack => output_ack,
			reset => reset,
			clk => clk);

    DP: inverterDataPath
	     port map (
	     		T => T,
			S => S,
			dvdr_start => dvdr_start,
			dvdr_output_ack => dvdr_output_ack,
			dvdr_input_ack => dvdr_input_ack,
			dvdr_done => dvdr_done,
			a => a,
			b => b,
			ir_polynom => ir_polynom,
			reset => reset,
			clk => clk);
end prost;

