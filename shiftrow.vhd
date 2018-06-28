library ieee;
use ieee.std_logic_1164.all;

entity shiftrow is
	port(x: in std_logic_vector(127 downto 0);
	     --clk:in std_logic;
	     y: out std_logic_vector(127 downto 0));
end entity;

architecture shift of shiftrow is
begin
 process(x)
 begin
   for i in 0 to 3 loop
     for j in 0 to 3 loop
	y((127-(8*(4*j+i))) downto (120-(8*(4*j+i)))) <= x((127-(8*((4*j+5*i) mod 16))) downto (120-(8*((4*j+5*i) mod 16))));
     end loop;
   end loop;
 end process;
end shift;
