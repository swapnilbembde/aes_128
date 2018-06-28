library ieee;
use ieee.std_logic_1164.all;

entity simplemul is
   port (a,b: in std_logic_vector(7 downto 0); c: out std_logic_vector(14 downto 0));
end entity;

architecture klep of simplemul is
	type product is array(7 downto 0) of std_logic_vector(7 downto 0);
	type longproduct is array(7 downto 0) of std_logic_vector(14 downto 0);
	signal p: product;
	signal longp: longproduct;
begin
    process(a,b)
    begin
	for i in 0 to 7 loop
		for j in 0 to 7 loop
			p(i)(j) <= a(j) and b(i);
		end loop;
	end loop;
    end process;
    longp(0) <= "0000000" & p(0);
    longp(1) <= "000000" & p(1) & "0";
    longp(2) <= "00000" & p(2) & "00";
    longp(3) <= "0000" & p(3) & "000";
    longp(4) <= "000" & p(4) & "0000";
    longp(5) <= "00" & p(5) & "00000";
    longp(6) <= "0" & p(6) & "000000";
    longp(7) <= p(7) & "0000000";

    c <= longp(0) xor longp(1) xor longp(2) xor longp(3) xor longp(4) xor longp(5) xor longp(6) xor longp(7);
end klep;



	
