library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity rkeygen is 
port(	key:in std_logic_vector(127 downto 0);
	ir_polynom: in std_logic_vector(8 downto 0);
	done:out std_logic;
	clk,reset,key_ack,start:in std_logic;
	round_key:out std_logic_vector(127 downto 0));
end entity;

architecture homie of rkeygen is 
	signal t: std_logic_vector(0 to 7);
	signal s: std_logic_vector(0 to 1);
	signal dvdr_output_ack,dvdr_start,dvdr_done,sbox_done,sbox_start,sbox_opack: std_logic;
begin
r1: rkeygencp port map(s=>s,t=>t,clk=>clk,reset=>reset,start=>start,done=>done,key_ack=>key_ack,dvdr_output_ack=>dvdr_output_ack,
                       dvdr_start=>dvdr_start,dvdr_done=>dvdr_done,sbox_done=>sbox_done,sbox_start=>sbox_start,sbox_opack=>sbox_opack);
r2: rkeygendp port map(s=>s,t=>t,clk=>clk,key=>key,round_key=>round_key,ir_polynom=>ir_polynom,dvdr_output_ack=>dvdr_output_ack,
                       dvdr_start=>dvdr_start,dvdr_done=>dvdr_done,reset=>reset,sbox_done=>sbox_done,sbox_start=>sbox_start,sbox_opack=>sbox_opack);
end homie;
------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity rkeygencp is
   port(s: in std_logic_vector(0 to 1);
	t: out std_logic_vector(0 to 7);
	clk,reset,key_ack,start,dvdr_done,sbox_done: in std_logic;
	done,dvdr_output_ack,dvdr_start,sbox_start,sbox_opack: out std_logic);
end entity;

architecture formula of rkeygencp is 
  type FsmState is (rst,constcomp,keycomp,donestate);
   signal fsm_state : FsmState;
begin
   process(fsm_state, s, start, clk, reset, key_ack,dvdr_done,sbox_done)
      variable next_state: FsmState;
      variable tvar: std_logic_vector(0 to 7);
      variable done_var,dvdr_start_var,dvdr_output_ack_var,ss_var,soa_var: std_logic;
  begin
	tvar := (others=>'0');
	next_state := fsm_state;
	done_var:='0'; dvdr_start_var:='0'; dvdr_output_ack_var:='0';ss_var:='0';soa_var:='0';

    case fsm_state is
	when rst =>
		if(start='1') then
			tvar(0 to 1):="11";     --roundkey:=key ;  count:=10;
			next_state:=donestate;
		else
			next_state:=rst;
		end if;
	when constcomp =>
		if s(1)='1' then                                --count==10
			tvar(4):='1'; tvar(6):='1';             --rcon:=1 ;  conpoly:=1;
			next_state:=keycomp;
		else
			if (dvdr_done /='1') then
				dvdr_start_var:='1';
				next_state:=constcomp;
			else
				dvdr_output_ack_var:='1'; tvar(5):='1';              --rcon:=(conpoly) mod prime
				next_state:=keycomp;
			end if;
		end if;


	when keycomp =>
		if sbox_done='0' then
			ss_var:='1';
			next_state:=keycomp;
		else
			soa_var:='1';
			tvar(2 to 3):="11";                      --roundkey:=f(roundkey);  count:=count-1;
			tvar(7):='1';			         --conpoly:=conpoly*x
			next_state:=donestate;
		end if;
	when donestate =>
		done_var:='1';
		if key_ack='1' then
			if s(0)='1' then                   --count==0
				next_state:=rst;
			else
				next_state:=constcomp;
			end if;
		else
			next_state:=donestate;
		end if;
    end case;	

t <= tvar;
done <= done_var;
dvdr_output_ack <= dvdr_output_ack_var; dvdr_start <= dvdr_start_var;
sbox_start<=ss_var; sbox_opack<=soa_var;


if(clk'event and (clk = '1')) then
	if(reset = '0') then
		 fsm_state <= next_state;
	else
		 fsm_state <= rst;
        end if;
end if;
end process;
end formula;

-----------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity rkeygendp is
   port(t: in std_logic_vector(0 to 7);
	s: out std_logic_vector(0 to 1);
	ir_polynom: in std_logic_vector(8 downto 0);
	clk,dvdr_start,dvdr_output_ack,reset,sbox_start,sbox_opack: in std_logic;
	dvdr_done,sbox_done: out std_logic;
	key:in std_logic_vector(127 downto 0);
	round_key:out std_logic_vector(127 downto 0));
end entity;

architecture formula of rkeygendp is
	signal count_en,r_en,key_en,c_en,sipack: std_logic;
	signal count,count_in,count_less,separate_done: std_logic_vector(3 downto 0);
	signal rcon,div_rcon,r_in: std_logic_vector(7 downto 0);
	signal rotword,subword,full_rcon,temp: std_logic_vector(31 downto 0);
	signal rkey,newkey,key_in: std_logic_vector(127 downto 0);
	signal shift_rcon: std_logic_vector(16 downto 0);
	signal conpoly,shift_conpoly,c_in: std_logic_vector(14 downto 0);

	constant c0: std_logic_vector(3 downto 0):=(others=>'0');
	constant c1: std_logic_vector(3 downto 0):=(0=>'1',others=>'0');
	constant c10: std_logic_vector(3 downto 0):=(3=>'1',1=>'1',others=>'0');
	constant c18: std_logic_vector(7 downto 0):=(0=>'1',others=>'0');
	constant c115: std_logic_vector(14 downto 0):=(0=>'1',others=>'0');
begin
--predicate
	s(0) <= '1' when count=c0 else '0';
	s(1) <= '1' when count=c10 else '0';
--count
	count_en <= t(1) or t(3);
	s1: subtractor4 port map (a=>count , b=>c1 , c=>count_less); 
	count_in <= c10 when (t(1)='1') else count_less;
	count_reg: DataRegister generic map(data_width=>4) port map(Din=>count_in , Dout=>count , Enable=>count_en , clk=>clk);
--conpoly
	c_en <= t(6) or t(7);

	shift_conpoly <= conpoly(13 downto 0) & "0";
	c_in <= c115 when t(6)='1' else shift_conpoly;

	c_reg: DataRegister generic map(data_width=>15) port map(Din=>c_in , Dout=>conpoly , Enable=>c_en , clk=>clk);
--rcon
	r_en <= t(4) or t(5);
	shift_rcon <= "00" & conpoly;

	d1: divider port map(dividend=>shift_rcon,divisor=>ir_polynom,r=>div_rcon,start=>dvdr_start,done=>dvdr_done,output_ack=>dvdr_output_ack,clk=>clk,reset=>reset);	

	r_in <= c18 when t(4)='1' else div_rcon;

	rcon_reg: DataRegister generic map(data_width=>8) port map(Din=>r_in , Dout=>rcon , Enable=>r_en , clk=>clk);

	full_rcon(31 downto 24)<=rcon;
	full_rcon(23 downto 0) <= (others=>'0');


--round key
	key_en <= t(0) or t(2);

	rotword <= rkey(23 downto 0) & rkey(31 downto 24);

	sub0: sbox port map (rotword(31 downto 24),subword(31 downto 24),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(0),clk,reset);
	sub1: sbox port map (rotword(23 downto 16),subword(23 downto 16),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(1),clk,reset);
	sub2: sbox port map (rotword(15 downto 8),subword(15 downto 8),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(2),clk,reset);
	sub3: sbox port map (rotword(7 downto 0),subword(7 downto 0),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(3),clk,reset);

	sbox_done <= separate_done(0) and separate_done(2) and separate_done(3) and separate_done(1); 

	temp <= subword xor full_rcon;
	
	newkey(127 downto 96) <= temp xor rkey(127 downto 96);
	newkey(95 downto 64) <= rkey(95 downto 64) xor newkey(127 downto 96);
	newkey(63 downto 32) <= rkey(63 downto 32) xor newkey(95 downto 64);
	newkey(31 downto 0) <= rkey(31 downto 0) xor newkey(63 downto 32);

	key_in<=key when t(0)='1' else newkey;

	key_reg: DataRegister generic map(data_width=>128) port map(Din=>key_in , Dout=>rkey , Enable=>key_en , clk=>clk);
	round_key<=rkey;
end formula;


