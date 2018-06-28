library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity mixcol is
   port(a: in std_logic_vector(31 downto 0);
	b: out std_logic_vector(31 downto 0);
	ir_polynom: in std_logic_vector(8 downto 0);
	start,clk,reset,output_ack: in std_logic;
	done: out std_logic);
end entity;

architecture full of mixcol is
	type some_vector is array(15 downto 0) of std_logic_vector(14 downto 0);
	signal p: some_vector;
	type a_vector is array(3 downto 0) of std_logic_vector(16 downto 0);
	signal dvnd: a_vector;

	signal d: std_logic_vector(15 downto 0);
	signal div0,div1,div2,div3: std_logic_vector(14 downto 0);
	signal div_done: std_logic_vector(3 downto 0);
	signal done_check,div_output_ack: std_logic;

	constant c07: std_logic_vector(6 downto 0):=(others=>'0');		
	constant c06: std_logic_vector(5 downto 0):=(others=>'0');		
	constant c3: std_logic_vector(7 downto 0):=(0=>'1',1=>'1',others=>'0');		
begin
--	m00: simplemul port map(a=>a(31 downto 24),b=>c2,c=>p(0),done=>d(0),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(0));
--	m01: simplemul port map(a=>a(23 downto 16),b=>c3,c=>p(1),done=>d(1),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(0)); 
--	m02: simplemul port map(a=>a(15 downto 8) ,b=>c1,c=>p(2),done=>d(2),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(0)); 
--	m03: simplemul port map(a=>a(7 downto 0)  ,b=>c1,c=>p(3),done=>d(3),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(0)); 
--
--	m10: simplemul port map(a=>a(31 downto 24),b=>c1,c=>p(4),done=>d(4),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(1));
--	m11: simplemul port map(a=>a(23 downto 16),b=>c2,c=>p(5),done=>d(5),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(1)); 
--	m12: simplemul port map(a=>a(15 downto 8) ,b=>c3,c=>p(6),done=>d(6),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(1)); 
--	m13: simplemul port map(a=>a(7 downto 0)  ,b=>c1,c=>p(7),done=>d(7),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(1)); 
--
--	m20: simplemul port map(a=>a(31 downto 24),b=>c1,c=>p(8) ,done=>d(8) ,start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(2));
--	m21: simplemul port map(a=>a(23 downto 16),b=>c1,c=>p(9) ,done=>d(9) ,start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(2)); 
--	m22: simplemul port map(a=>a(15 downto 8) ,b=>c2,c=>p(10),done=>d(10),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(2)); 
--	m23: simplemul port map(a=>a(7 downto 0)  ,b=>c3,c=>p(11),done=>d(11),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(2)); 
--
--	m30: simplemul port map(a=>a(31 downto 24),b=>c3,c=>p(12),done=>d(12),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(3));
--	m31: simplemul port map(a=>a(23 downto 16),b=>c1,c=>p(13),done=>d(13),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(3)); 
--	m32: simplemul port map(a=>a(15 downto 8) ,b=>c1,c=>p(14),done=>d(14),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(3)); 
--	m33: simplemul port map(a=>a(7 downto 0)  ,b=>c2,c=>p(15),done=>d(15),start=>start,clk=>clk,reset=>reset,output_ack=>div_ipack(3)); 

	p(0) <= c06 & a(31 downto 24) & "0";
	p(1) <= c06 & (("0" & a(23 downto 16)) xor (a(23 downto 16) & "0"));
	p(2) <= c07 & a(15 downto 8);
	p(3) <= c07 & a(7 downto 0);

	p(4) <= c07 & a(31 downto 24);
	p(5) <= c06 & a(23 downto 16) & "0";
	p(6) <= c06 & (("0" & a(15 downto 8)) xor (a(15 downto 8) & "0"));
	p(7) <= c07 & a(7 downto 0);

	p(8) <= c07 & a(31 downto 24);
	p(9) <= c07 & a(23 downto 16);
	p(10) <= c06 & a(15 downto 8) & "0";
	p(11) <= c06 & (("0" & a(7 downto 0)) xor (a(7 downto 0) & "0"));

	p(12) <=c06 & (("0" & a(31 downto 24)) xor (a(31 downto 24) & "0"));
	p(13) <= c07 & a(23 downto 16);
	p(14) <= c07 & a(15 downto 8);
	p(15) <= c06 & a(7 downto 0) & "0";

	div0<=p(0)xor p(1)xor p(2)xor p(3);
	div1<=p(4)xor p(5)xor p(6)xor p(7);
	div2<=p(8)xor p(9)xor p(10)xor p(11);
	div3<=p(12)xor p(13)xor p(14)xor p(15);

--	div_start(0)<=d(0)and d(1)and d(2)and d(3);
--	div_start(1)<=d(4)and d(5)and d(6)and d(7);
--	div_start(2)<=d(8)and d(9)and d(10)and d(11);
--	div_start(3)<=d(12)and d(13)and d(14)and d(15);

	dvnd(0)<="00" & div0;
	dvnd(1)<="00" & div1;
	dvnd(2)<="00" & div2;
	dvnd(3)<="00" & div3;
	--b(31 downto 24)<= div0(7 downto 0);
	--b(23 downto 16)<= div1(7 downto 0);
	--b(15 downto 8)<= div2(7 downto 0);
	--b(7 downto 0)<= div3(7 downto 0);
	dvdr0:divider port map(dividend=>dvnd(0),divisor=>ir_polynom,r=>b(31 downto 24),output_ack=>div_output_ack,
				start=>start,done=>div_done(0),clk=>clk,reset=>reset);  

	dvdr1:divider port map(dividend=>dvnd(1),divisor=>ir_polynom,r=>b(23 downto 16),output_ack=>div_output_ack,
				start=>start,done=>div_done(1),clk=>clk,reset=>reset);  

	dvdr2:divider port map(dividend=>dvnd(2),divisor=>ir_polynom,r=>b(15 downto 8),output_ack=>div_output_ack,
				start=>start,done=>div_done(2),clk=>clk,reset=>reset);  

	dvdr3:divider port map(dividend=>dvnd(3),divisor=>ir_polynom,r=>b(7 downto 0),output_ack=>div_output_ack,
				start=>start,done=>div_done(3),clk=>clk,reset=>reset);  
	

	done_check <= div_done(0)and div_done(1)and div_done(2)and div_done(3);
	div_output_ack <= done_check and output_ack;       --makes sure that all dividers are done before sending any one back to rst  
	done <= done_check;

end full;
