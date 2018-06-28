library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;


entity encrypt is
   port(plaindata: in std_logic_vector(127 downto 0);
	cipherdata: out std_logic_vector(127 downto 0);
	key: in std_logic_vector(127 downto 0);
	start,reset,clk: in std_logic;
	done: out std_logic;
	ir_polynom: in std_logic_vector(8 downto 0));
end entity;

architecture aes of encrypt is
	signal mixcol_done,keygen_done,mixcol_start,mixcol_opack,key_ack,s,s2,p2,sbox_done,sbox_start,sbox_opack: std_logic;
	signal t: std_logic_vector(0 to 7);
begin
ecp: encryptcp port map(t=>t,s=>s,start=>start,mixcol_done=>mixcol_done,keygen_done=>keygen_done,mixcol_start=>mixcol_start,
			mixcol_opack=>mixcol_opack,key_ack=>key_ack,done=>done,sbox_done=>sbox_done,sbox_start=>sbox_start,sbox_opack=>sbox_opack,reset=>reset,clk=>clk,p2 => p2,s2 => s2);
edp: encryptdp port map(t=>t,s=>s,plaindata=>plaindata,key=>key,cipherdata=>cipherdata,ir_polynom=>ir_polynom,mixcol_done=>mixcol_done,
			keygen_done=>keygen_done,mixcol_start=>mixcol_start,mixcol_opack=>mixcol_opack,keygen_start=>start,
			key_ack=>key_ack,reset=>reset,clk=>clk,p2 => p2,s2 =>s2,sbox_done=>sbox_done,sbox_start=>sbox_start,sbox_opack=>sbox_opack);
end aes;

------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity encryptcp is
   port(t: out std_logic_vector(0 to 7);
	s,s2: in std_logic;
	start,mixcol_done,keygen_done,reset,clk,sbox_done: in std_logic;
	done,mixcol_start,mixcol_opack,key_ack,p2,sbox_start,sbox_opack: out std_logic);
end entity;

architecture aes of encryptcp is
   type FsmState is (rst, substi, rowshift, mixcolumn, key, fin);
   signal fsm_state : FsmState;
begin
   process(fsm_state, s,s2, start, clk, reset, mixcol_done, keygen_done)
      variable next_state: FsmState;
      variable tvar: std_logic_vector(0 to 7);
      variable done_var,mcs_var,mcoa_var,ka_var,soa_var,ss_var,p1: std_logic;
  begin
	tvar := (others=>'0');
	next_state := fsm_state;
	done_var :='0'; mcs_var:='0'; mcoa_var:='0'; ka_var:='0';soa_var:='0'; ss_var:='0'; p1:='0';
	
    case fsm_state is
	when rst =>
	     if(start='1') then
			next_state := key;
			tvar(1):='1'; tvar(6):='1';           --t(6)='1' => data:=plaindata     ;    t(1)='1' => count:=10
		else
			next_state:=rst;
		end if;
--	when sup =>
--		if keygen_done='1' then
--			ka_var:='1';
--			next_state:=substi;
--		else
--			next_state:=sup;
--		end if;
	when substi =>
		if(s2='1') then
		    p1:='1';
		end if;
		if sbox_done='0' then
			ss_var:='1';
			next_state:=substi;
		else
			soa_var:='1';
			tvar(2):='1';                          --op:=substitution
			next_state:=rowshift;
		end if;
	when rowshift =>
		tvar(3):='1';                          --op:=rowshift
		if (s='1') then
			next_state := key;
		else
			next_state := mixcolumn;
		end if;
	when mixcolumn =>

		if mixcol_done='0' then
		 	mcs_var:='1';
			next_state := mixcolumn;
		else
			mcoa_var:='1';
			tvar(4):='1';		       --op:=mixcol
			next_state := key;
		end if;
	when key =>
		if keygen_done='1' then
			tvar(0):='1';                     --op:=op xor key
			ka_var:='1';
			if s='1' then
				tvar(7):='1';             --cipherdata:=op xor key
				next_state:=fin;
			else
				tvar(5):='1';             --count--
				next_state:=substi;
			end if;
		else
			next_state:=key;
		end if;
	when fin =>
		done_var:='1';
		next_state:=rst;
    end case;
t <= tvar;
done <= done_var;
mixcol_start <= mcs_var; mixcol_opack <= mcoa_var;
sbox_start <= ss_var; sbox_opack <= soa_var;
key_ack <= ka_var;
p2<=p1;

if(clk'event and clk = '1') then
	if(reset = '0') then
		 fsm_state <= next_state;
	else
		 fsm_state <= rst;
        end if;
end if;
end process;
end aes;

----------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.general_components.all;

entity encryptdp is
   port(t: in std_logic_vector(0 to 7);
	s,s2: out std_logic;
	plaindata,key: in std_logic_vector(127 downto 0);
	cipherdata: out std_logic_vector(127 downto 0);
	ir_polynom: in std_logic_vector(8 downto 0);
	mixcol_done,keygen_done,sbox_done: out std_logic;
	mixcol_start,mixcol_opack,sbox_start,sbox_opack,keygen_start,key_ack,reset,clk,p2: in std_logic);
end entity;

architecture aes of encryptdp is
	signal sbdata,rsdata,mcdata,kdata,rkey,key_fl,data_in,data,data_xor: std_logic_vector(127 downto 0);
	signal mc_done,count_in,count,count_less: std_logic_vector(3 downto 0);
	signal count_en,data_en,mixcol1_done,sipack: std_logic;
	signal separate_done: std_logic_vector(15 downto 0);
	
	constant c0: std_logic_vector(3 downto 0):=(others=>'0');
	constant c1: std_logic_vector(3 downto 0):=(0=>'1',others=>'0');
	constant c10: std_logic_vector(3 downto 0):=(3=>'1',1=>'1',others=>'0');
begin
--predicate
	s <= '1' when count=c0	else '0';
	s2 <= '1' when count="1010" else '0';
--count
	count_en <= t(1) or t(5);
	sub: subtractor4 port map (a=>count , b=>c1 , c=>count_less); 
	count_in <= c10 when (t(1)='1') else count_less;
	count_reg: DataRegister generic map(data_width=>4) port map(Din=>count_in , Dout=>count , Enable=>count_en , clk=>clk);

--	data_xor <= plaindata xor key;
--	data<= data_xor when p2='1' else data;

--sbox
	s00: sbox port map (data(7 downto 0),sbdata(7 downto 0),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(0),clk,reset);
	s01: sbox port map (data(15 downto 8),sbdata(15 downto 8),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(1),clk,reset);	
	s02: sbox port map (data(23 downto 16),sbdata(23 downto 16),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(2),clk,reset);
	s03: sbox port map (data(31 downto 24),sbdata(31 downto 24),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(3),clk,reset);
	s04: sbox port map (data(39 downto 32),sbdata(39 downto 32),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(4),clk,reset);
	s05: sbox port map (data(47 downto 40),sbdata(47 downto 40),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(5),clk,reset);
	s06: sbox port map (data(55 downto 48),sbdata(55 downto 48),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(6),clk,reset);
	s07: sbox port map (data(63 downto 56),sbdata(63 downto 56),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(7),clk,reset);
	s08: sbox port map (data(71 downto 64),sbdata(71 downto 64),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(8),clk,reset);
	s09: sbox port map (data(79 downto 72),sbdata(79 downto 72),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(9),clk,reset);
	s10: sbox port map (data(87 downto 80),sbdata(87 downto 80),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(10),clk,reset);
	s11: sbox port map (data(95 downto 88),sbdata(95 downto 88),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(11),clk,reset);	
	s12: sbox port map (data(103 downto 96),sbdata(103 downto 96),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(12),clk,reset);
	s13: sbox port map (data(111 downto 104),sbdata(111 downto 104),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(13),clk,reset);	
	s14: sbox port map (data(119 downto 112),sbdata(119 downto 112),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(14),clk,reset);	
	s15: sbox port map (data(127 downto 120),sbdata(127 downto 120),ir_polynom,sbox_start,sbox_opack,sipack,separate_done(15),clk,reset);	

--	process(separate_done)
--		variable sdone_var:std_logic:='1';
--	begin	
--		for i in 0 to 15 loop
--			sdone_var:=sdone_var and separate_done(i);
--		end loop;
--		sbox_done <= sdone_var;
--	end process;

	sbox_done <= separate_done(0) and separate_done(1) and separate_done(2) and separate_done(3) and separate_done(4) and separate_done(5) and separate_done(6) and separate_done(7) and separate_done(8) and separate_done(9) and separate_done(10) and separate_done(11) and separate_done(12) and separate_done(13) and separate_done(14) and separate_done(15);
--rowshift
	rs: shiftrow port map (x=>data, y=>rsdata);  
--mixcolumn
	mc0: mixcol port map (a=>data(31 downto 0),b=>mcdata(31 downto 0),ir_polynom=>ir_polynom,start=>mixcol_start,done=>mc_done(0),
				clk=>clk,reset=>reset,output_ack=>mixcol_opack);
	mc1: mixcol port map (a=>data(63 downto 32),b=>mcdata(63 downto 32),ir_polynom=>ir_polynom,start=>mixcol_start,done=>mc_done(1),
				clk=>clk,reset=>reset,output_ack=>mixcol_opack);
	mc2: mixcol port map (a=>data(95 downto 64),b=>mcdata(95 downto 64),ir_polynom=>ir_polynom,start=>mixcol_start,done=>mc_done(2),
				clk=>clk,reset=>reset,output_ack=>mixcol_opack);
	mc3: mixcol port map (a=>data(127 downto 96),b=>mcdata(127 downto 96),ir_polynom=>ir_polynom,start=>mixcol_start,done=>mc_done(3),
				clk=>clk,reset=>reset,output_ack=>mixcol_opack);
	mixcol1_done<=mc_done(0) and mc_done(1) and mc_done(2) and mc_done(3);
	mixcol_done <= '0' when t(3) ='1' else mixcol1_done;
--key
	rkg: rkeygen port map(key=>key,ir_polynom=>ir_polynom,done=>keygen_done,round_key=>rkey,start=>keygen_start,key_ack=>key_ack,clk=>clk,reset=>reset);
--	key_fl <= key when p2='1' else rkey;
	kdata <= data xor rkey;
--otuput data
	data_en <= t(0) or t(2) or t(3) or t(4) or t(6);
	data_in <= kdata when t(0)='1' else sbdata when t(2)='1' else rsdata when t(3)='1' else mcdata when t(4)='1' else plaindata;
	data_reg: DataRegister generic map(data_width=>128) port map(Din=>data_in , Dout=>data , Enable=>data_en , clk=>clk);

--cipherdata
	cipherdata_reg: DataRegister generic map(data_width=>128) port map(Din=>kdata , Dout=>cipherdata , Enable=>t(7) , clk=>clk);

end aes;
