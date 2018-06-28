
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity inverterDataPath is
	port (  T: in std_logic_vector(0 to 14);
		dvdr_start,dvdr_output_ack: in std_logic;
		S,dvdr_input_ack,dvdr_done: out std_logic;
		a: in std_logic_vector(7 downto 0);
		b: out std_logic_vector(7 downto 0);
		ir_polynom: in std_logic_vector(8 downto 0);
		clk, reset: in std_logic
	     );
end entity;

architecture prost of inverterDataPath is
	signal ct,newt,intert,ct_in,nt_in,nt_next,quo,rmn: std_logic_vector(7 downto 0);
	signal prod: std_logic_vector(14 downto 0);
	signal dvnd,dvnd_in,fullprod,fullr: std_logic_vector(16 downto 0);
	signal r,newr,interr,dvsr,dvsr_in,semifulla,semifullr,nr_in,r_in: std_logic_vector(8 downto 0);

	signal dvnd_en,dvsr_en,r_en,ct_en,nr_en,nt_en,ir_en,it_en: std_logic;

	constant c09: std_logic_vector(8 downto 0) := (others=>'0');
	constant c08: std_logic_vector(7 downto 0) := (others=>'0');
	constant c18: std_logic_vector(7 downto 0) := (0=>'1',others=>'0');
begin
--prediacte
	S <= '1' when (newr = c09) else '0';
--divider
	d0:divider port map(dividend=>dvnd,divisor=>dvsr,q=>quo,r=>rmn,done=>dvdr_done,input_ack=>dvdr_input_ack,
			    output_ack=>dvdr_output_ack,start=>dvdr_start,clk=>clk,reset=>reset);
--dvnd
	dvnd_en <= T(6) or T(10);
	fullr <= c08 & r;
	m0: simplemul port map(a=>quo,b=>newt,c=>prod);
	fullprod <= "00" & prod;
	dvnd_in <= fullr when T(6)='1' else fullprod;
	dvnd_reg: DataRegister generic map(data_width=>17) port map(Din=>dvnd_in , Dout=>dvnd , Enable=>dvnd_en , clk=>clk);
--dvsr
	dvsr_en <= T(7) or T(11);
	dvsr_in <= newr when T(7)='1' else ir_polynom;
	dvsr_reg: DataRegister generic map(data_width=>9) port map(Din=>dvsr_in , Dout=>dvsr , Enable=>dvsr_en , clk=>clk);
--newr
	nr_en <= T(0) or T(9);
	semifulla <= "0" & a;	
	semifullr <= "0" & rmn;
	nr_in <= semifulla when T(0)='1' else semifullr;
	nr_reg: DataRegister generic map(data_width=>9) port map(Din=>nr_in , Dout=>newr , Enable=>nr_en , clk=>clk);
--r
	r_en <= T(1) or T(8);
	r_in <= ir_polynom when T(1)='1' else interr;
	r_reg: DataRegister generic map(data_width=>9) port map(Din=>r_in , Dout=>r , Enable=>r_en , clk=>clk);
--interr
	ir_reg: DataRegister generic map(data_width=>9) port map(Din=>newr , Dout=>interr , Enable=>T(4) , clk=>clk);
--intert
	it_reg: DataRegister generic map(data_width=>8) port map(Din=>newt , Dout=>intert , Enable=>T(5) , clk=>clk);
--newt
	nt_en <= T(3) or T(13);
	nt_next <= ct xor rmn; 
	nt_in <= c18 when T(3)='1' else nt_next;
	nt_reg: DataRegister generic map(data_width=>8) port map(Din=>nt_in , Dout=>newt , Enable=>nt_en , clk=>clk);
--t
	ct_en <= T(2) or T(12);
	ct_in <= c08 when T(2)='1' else intert;
	ct_reg: DataRegister generic map(data_width=>8) port map(Din=>ct_in , Dout=>ct , Enable=>ct_en , clk=>clk);
--result
	result_reg: DataRegister generic map(data_width=>8) port map(Din=>ct , Dout=>b , Enable=>T(14) , clk=>clk);
end prost;
--though for a=01 output of dividing irp by 1, quo should be length 9 which is not possible with divider thus the algo proceeds in wrong direction from the beginning. However, final result(inverse) comesout to be correct.
