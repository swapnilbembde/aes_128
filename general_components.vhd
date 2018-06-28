library std;
library ieee;
use ieee.std_logic_1164.all;

package general_components is
	component DataRegister is
		generic (data_width:integer);
		port (Din: in std_logic_vector(data_width-1 downto 0);
		      Dout: out std_logic_vector(data_width-1 downto 0);
		      clk, enable: in std_logic);
	end component DataRegister;

	component subtractor4 is
		port (a,b: in std_logic_vector(3 downto 0); c: out std_logic_vector(3 downto 0));
	end component subtractor4;

	component dividerdp is
	   port(t: in std_logic_vector(0 to 10);
		s: out std_logic;
		a: in std_logic_vector(16 downto 0);
		b: in std_logic_vector(8 downto 0);
		q: out std_logic_vector(7 downto 0);
		r: out std_logic_vector(7 downto 0);
		clk: in std_logic);
	end component;

	component dividercp is
	   port(done,input_ack: out std_logic;
		clk,reset,start,output_ack: in std_logic;
		t: out std_logic_vector(0 to 10);
		s: in std_logic);
	end component;

	component checker is
	   port(a: in std_logic_vector(8 downto 0);
		b: in std_logic_vector(8 downto 0);
		c: out std_logic);
	end component;
	component simplemul is
	   port (a,b: in std_logic_vector(7 downto 0); c: out std_logic_vector(14 downto 0));
	end component;

	component divider is
	   port(dividend: in std_logic_vector(16 downto 0);
		divisor: in std_logic_vector(8 downto 0); 
		q: out std_logic_vector(7 downto 0); 
		r: out std_logic_vector(7 downto 0); 
		done,input_ack: out std_logic;
		clk,reset,start,output_ack: in std_logic);
	end component;

	component inverterControlPath is 
		port (  T:out std_logic_vector(0 to 14);
			dvdr_start,dvdr_output_ack: out std_logic;
			S,dvdr_input_ack,dvdr_done: in std_logic;
			start,output_ack: in std_logic;
			input_ack,done : out std_logic;
			clk, reset: in std_logic
		     );
	end component;
	component inverterDataPath is
		port (  T: in std_logic_vector(0 to 14);
			dvdr_start,dvdr_output_ack: in std_logic;
			S,dvdr_input_ack,dvdr_done: out std_logic;
			a: in std_logic_vector(7 downto 0);
			b: out std_logic_vector(7 downto 0);
			ir_polynom: in std_logic_vector(8 downto 0);
			clk, reset: in std_logic
		     );
	end component;
	component inverter is 
	  port(a: in std_logic_vector(7 downto 0);
	       b: out std_logic_vector(7 downto 0);
	       ir_polynom: in std_logic_vector(8 downto 0);
	       start,output_ack: in std_logic;
	       input_ack,done: out std_logic;
	       clk, reset: in std_logic);
	end component;

	component sbox is 
	  port(input: in std_logic_vector(7 downto 0);
	       output: out std_logic_vector(7 downto 0);
	       ir_polynom: in std_logic_vector(8 downto 0);
	       start,output_ack: in std_logic;
	       input_ack,done: out std_logic;
	       clk, reset: in std_logic);
	end component;
	component mixcol is
	   port(a: in std_logic_vector(31 downto 0);
		b: out std_logic_vector(31 downto 0);
		ir_polynom: in std_logic_vector(8 downto 0);
		start,clk,reset,output_ack: in std_logic;
		done: out std_logic);
	end component;
	component shiftrow is
		port(x: in std_logic_vector(127 downto 0);
		     y: out std_logic_vector(127 downto 0));
	end component;

	component rkeygendp is
	   port(t: in std_logic_vector(0 to 7);
		s: out std_logic_vector(0 to 1);
		ir_polynom: in std_logic_vector(8 downto 0);
		clk,dvdr_start,dvdr_output_ack,reset,sbox_start,sbox_opack: in std_logic;
		dvdr_done,sbox_done: out std_logic;
		key:in std_logic_vector(127 downto 0);
		round_key:out std_logic_vector(127 downto 0));
	end component;
	component rkeygencp is
	   port(s: in std_logic_vector(0 to 1);
		t: out std_logic_vector(0 to 7);
		clk,reset,key_ack,start,dvdr_done,sbox_done: in std_logic;
		done,dvdr_output_ack,dvdr_start,sbox_start,sbox_opack: out std_logic);
	end component;
	component rkeygen is 
	port(	key:in std_logic_vector(127 downto 0);
		ir_polynom: in std_logic_vector(8 downto 0);
		done:out std_logic;
		clk,reset,key_ack,start:in std_logic;
		round_key:out std_logic_vector(127 downto 0));
	end component;

	component encryptdp is
	   port(t: in std_logic_vector(0 to 7);
		s,s2: out std_logic;
		plaindata,key: in std_logic_vector(127 downto 0);
		cipherdata: out std_logic_vector(127 downto 0);
		ir_polynom: in std_logic_vector(8 downto 0);
		mixcol_done,keygen_done,sbox_done: out std_logic;
		mixcol_start,mixcol_opack,sbox_start,sbox_opack,keygen_start,key_ack,reset,clk,p2: in std_logic);
	end component;
	component encryptcp is
	   port(t: out std_logic_vector(0 to 7);
		s,s2: in std_logic;
		start,mixcol_done,keygen_done,reset,clk,sbox_done: in std_logic;
		done,mixcol_start,mixcol_opack,key_ack,p2,sbox_start,sbox_opack: out std_logic);
	end component;
end package;
