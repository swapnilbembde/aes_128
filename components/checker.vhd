library ieee;
use ieee.std_logic_1164.all;

entity checker is
   port(a: in std_logic_vector(8 downto 0);
	b: in std_logic_vector(8 downto 0);
	c: out std_logic);
end entity;

architecture now of checker is
  signal x,y:std_logic_vector(3 downto 0);
begin
     x<="1001"when a(8)='1' else
	"1000"when a(7)='1' else
	"0111"when a(6)='1' else
	"0110"when a(5)='1' else
	"0101"when a(4)='1' else
	"0100"when a(3)='1' else
	"0011"when a(2)='1' else
	"0010"when a(1)='1' else
	"0001"when a(0)='1' else
	"1011";
     y<="1001"when b(8)='1' else
	"1000"when b(7)='1' else
	"0111"when b(6)='1' else
	"0110"when b(5)='1' else
	"0101"when b(4)='1' else
	"0100"when b(3)='1' else
	"0011"when b(2)='1' else
	"0010"when b(1)='1' else
	"0001"when b(0)='1' else
	"1111";
c<=(x(3) xnor y(3)) and (x(2) xnor y(2)) and (x(1) xnor y(1)) and (x(0) xnor y(0));
end now;
