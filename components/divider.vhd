library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity divider is
   port(dividend: in std_logic_vector(16 downto 0);
	divisor: in std_logic_vector(8 downto 0); 
	q: out std_logic_vector(7 downto 0); 
	r: out std_logic_vector(7 downto 0); 
	done,input_ack: out std_logic;
	clk,reset,start,output_ack: in std_logic);
end entity;

architecture icing of divider is
	signal t: std_logic_vector(0 to 10);
	signal s: std_logic;
begin
cp:dividercp port map(done=>done,
			start=>start,
			t=>t,
			s=>s,
			input_ack => input_ack,
			output_ack => output_ack,
			clk=>clk,
			reset=>reset);
dp:dividerdp port map(a=>dividend,
			b=>divisor,	
			q=>q,
			r=>r,
			t=>t,
			s=>s,
			clk=>clk);						
end icing;

---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dividercp is
   port(done,input_ack: out std_logic;
	clk,reset,start,output_ack: in std_logic;
	t: out std_logic_vector(0 to 10);
	s: in std_logic);
end entity;

architecture cake of dividercp is
   type FsmState is (rst, compute, shift, donestate);
   signal fsm_state : FsmState;
begin
   process(fsm_state, s, start, clk, reset)
      variable next_state: FsmState;
      variable tvar: std_logic_vector(0 to 10);
      variable done_var,ipack_var: std_logic;
  begin
	tvar := (others=>'0');
	next_state := fsm_state;
	done_var :='0'; ipack_var:='0';
	
    case fsm_state is
	when rst =>
		if(start='1') then
			ipack_var:='1';
			next_state := shift;
			tvar(0 to 3) := "1111";
		else
			next_state := rst;
		end if;
	when shift =>
		next_state := compute;
		tvar(4 to 7) := "1111";
	when compute =>
		tvar(8 to 9) := "11";
		if (s='1') then
			next_state := donestate;
			tvar(10) := '1';
		else
			next_state:= shift;
		end if;
	when donestate =>
		done_var := '1';
		if output_ack='1' then
			next_state := rst;
		else
			next_state := donestate;
		end if;
    end case;

--dvnd =  _   _  [14][13][12][11][10][9][8][7][6][5][4][3][2][1][0]
--dvsr =  [8] [7] [6] [5] [4] [3] [2][1][0] _  _  _  _  _  _  _  _  


t <= tvar;
done <= done_var;
input_ack <= ipack_var;

if(clk'event and (clk = '1')) then
	if(reset = '0') then
		 fsm_state <= next_state;
	else
		 fsm_state <= rst;
        end if;
end if;
end process;
end cake;
			
----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity dividerdp is
   port(t: in std_logic_vector(0 to 10);
	s: out std_logic;
	a: in std_logic_vector(16 downto 0);
	b: in std_logic_vector(8 downto 0);
	q: out std_logic_vector(7 downto 0);
	r: out std_logic_vector(7 downto 0);
	clk: in std_logic);
end entity;

architecture cake of dividerdp is
	signal a_en,count_en,q_en: std_logic;
	signal check_in,check: std_logic_vector(0 downto 0);	
	signal a_shift,a_reg,a_in,a_new: std_logic_vector(16 downto 0);	
	signal b_reg,temp: std_logic_vector(8 downto 0);	
	signal q_reg,q_shift,q_in,q_new: std_logic_vector(7 downto 0);
	signal count,count_less,count_in: std_logic_vector(3 downto 0);

	constant c04: std_logic_vector(3 downto 0):=(others=>'0');
	constant c14: std_logic_vector(3 downto 0):=(0=>'1',others=>'0');
	constant c84: std_logic_vector(3 downto 0):=(3=>'1',others=>'0');
	constant c09: std_logic_vector(8 downto 0):=(others=>'0');
	constant c08: std_logic_vector(7 downto 0):=(others=>'0');

begin
--predicate
	s <= '1' when (count=c04) else '0';
--check
	c1: checker port map (a=>a_reg(15 downto 7) , b=>b_reg , c=>check_in(0));
	check_register: DataRegister generic map(data_width=>1) port map(Din=>check_in , Dout=>check , Enable=>t(6) , clk=>clk);
--count	
	count_en <= t(3) or t(7);
	s1: subtractor4 port map (a=>count , b=>c14 , c=>count_less); 
	count_in <= c84 when t(3)='1' else count_less;
	count_reg: DataRegister generic map(data_width=>4) port map(Din=>count_in , Dout=>count , Enable=>count_en , clk=>clk);
--a
	a_en <= t(0) or t(4) or t(8);
	a_shift <= a_reg(15 downto 0) & "0";

	temp <= b_reg when (check="1") else c09;
	a_new(16 downto 8) <= a_reg(16 downto 8) xor temp;
	a_new (7 downto 0) <= a_reg(7 downto 0);

	a_in <= a when t(0)='1' else a_shift when t(4) ='1' else a_new;
	a_register: DataRegister generic map(data_width=>17) port map(Din=>a_in , Dout=>a_reg , Enable=>a_en , clk=>clk); 	
--b
	b_register: DataRegister generic map(data_width=>9) port map(Din=>b , Dout=>b_reg , Enable=>t(1) , clk=>clk); 	
--q
	q_en <= t(2) or t(5) or t(9);
	q_shift <= q_reg(6 downto 0) & "0";
	q_new <= q_reg(7 downto 1) & check;	

	q_in <= c08 when t(2)='1' else q_shift when t(5)='1' else q_new;
	q_register: DataRegister generic map(data_width=>8) port map(Din=>q_in , Dout=>q_reg , Enable=>q_en , clk=>clk); 	
	q <= q_reg;
--r
	r_register: DataRegister generic map(data_width=>8) port map(Din=>a_new(15 downto 8) , Dout=>r , Enable=>t(10) , clk=>clk); 	
end cake;
