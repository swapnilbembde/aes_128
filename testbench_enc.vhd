library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;

entity testbench is
end entity;

architecture behave of testbench is
component encrypt is
   port(plaindata: in std_logic_vector(127 downto 0);
	cipherdata: out std_logic_vector(127 downto 0);
	key: in std_logic_vector(127 downto 0);
	start,reset,clk: in std_logic;
	done: out std_logic;
	ir_polynom: in std_logic_vector(8 downto 0));
end component;
signal plaindata,cipherdata,key:std_logic_vector(127 downto 0);
signal start:std_logic;
signal clk:std_logic:='0';
signal reset:std_logic:='1';
signal done:std_logic;
signal ir_polynom: std_logic_vector(8 downto 0):="100011011";
function to_std_logic_vector(x: bit_vector) return std_logic_vector is
    alias lx: bit_vector(1 to x'length) is x;
    variable ret_var : std_logic_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else 
           ret_var(I) :=  '0';
	end if;
     end loop;
     return(ret_var);
  end to_std_logic_vector;

function to_std_logic(x: bit) return std_logic is
      variable ret_val: std_logic;
  begin  
      if (x = '1') then
        ret_val := '1';
      else 
        ret_val := '0';
      end if;
      return(ret_val);
  end to_std_logic;

function to_bit_vector(x: std_logic_vector) return bit_vector is
    alias lx: std_logic_vector(1 to x'length) is x;
    variable ret_var : bit_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else 
           ret_var(I) :=  '0';
	end if;
     end loop;
     return(ret_var);
  end to_bit_vector;

function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin  
      ret_val := lx;
      return(ret_val);
  end to_string;

begin

clk <= not clk after 5 ns;
 process
begin
     wait until clk = '1';
     reset <= '0';
     wait;
  end process;
process 
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "TRACE1.txt";
    FILE OUTFILE: text  open write_mode is "OUTPUTS4.txt";

    ---------------------------------------------------
    -- edit the next two lines to customize
    variable in_d: bit_vector (127 downto 0);
    variable out_d: bit_vector (127 downto 0);
    variable k: bit_vector (127 downto 0);
   
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

 begin
    wait until clk = '1';
    while not endfile(INFILE) loop 
          LINE_COUNT := LINE_COUNT + 1;
	
	  readLine (INFILE, INPUT_LINE);
          read (INPUT_LINE, in_d);
          read (INPUT_LINE, out_d);
          read (INPUT_LINE, k);

  	  plaindata <= to_std_logic_vector(in_d);
	  key <= to_std_logic_vector(k);
 		 start <= '1';
	  while (true) loop
             wait until clk = '1';
             start <= '0';
             if(done = '1') then
                exit;
             end if;
          end loop;

	  wait for 10 ns;

--------------------------------------
	  -- check outputs.

 	  if (cipherdata /= to_std_logic_Vector(out_d)) then
             write(OUTPUT_LINE,to_string("ERROR: in output: "));
             write(OUTPUT_LINE, to_bit_vector(cipherdata));
             writeline(OUTFILE, OUTPUT_LINE);
             err_flag := true;
          
          end if;

end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;
dut: encrypt
port map(plaindata => plaindata, cipherdata => cipherdata, key => key, ir_polynom => ir_polynom, start => start, done => done, clk => clk,reset => reset);

end behave;


