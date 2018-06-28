library ieee;
use ieee.std_logic_1164.all;
entity subtractor4 is
   port (a,b: in std_logic_vector(3 downto 0); c: out std_logic_vector(3 downto 0));
end entity;
architecture Serial of subtractor4 is
begin
   process(a,b)
     variable carry: std_logic;
   begin
     carry := '1';
     for I in 0 to 3 loop
        c(I) <= (a(I) xor (not b(I))) xor carry;
        carry := (carry and (a(I) or (not b(I)))) or (a(I) and (not b(I)));
     end loop;
   end process;
end Serial;

