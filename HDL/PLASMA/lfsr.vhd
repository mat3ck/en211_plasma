library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lsfr is
	generic (
		nbits	: integer := 32
	);
	port (
		clk		: in  std_logic;
		rst		: in  std_logic;
		en_i	: in  std_logic;
		seed_i	: in  std_logic_vector (nbits-1 downto 0);
		per_i	: in  std_logic_vector (nbits-1 downto 0);
		
		val_o	: out std_logic_vector (nbits-1 downto 0);
		ready_o	: out std_logic
	);
end lsfr;

architecture Behavioral of lsfr is

	constant NBITS_PERIOD	: integer := nbits;
	constant PERIOD_MAX		: integer range 0 to 2147483647 := 2**(NBITS_PERIOD-1) - 1;
	
	signal state		: std_logic := '0';
	signal s_val		: unsigned (nbits-1 downto 0);
	signal s_val_new	: unsigned (nbits-1 downto 0);
	
	signal s_rst	: std_logic := '0';
	signal s_en		: std_logic := '0';
	signal s_cycles	: std_logic_vector (nbits-1 downto 0);

begin

	counter_state : entity work.stop_counter
		generic map (
			nbits	=> NBITS_PERIOD,
			nmax	=> PERIOD_MAX
		)
		port map (
			clk			=> clk,
			rst			=> s_rst,
			enable		=> s_en,
			data		=> s_cycles,
			overflow	=> open
		);
	
	output: process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				s_rst	<= '1';
				s_en	<= '0';
				state	<= '0';
				ready_o	<= '0';
			else
				if en_i = '1' and state = '0' then
					state	<= '1';
					s_en	<= '1';
					s_rst	<= '0';
					ready_o	<= '0';
				elsif state = '1' and (s_cycles > per_i) then
					state	<= '0';
					s_en	<= '0';
					s_rst	<= '1';
					val_o	<= std_logic_vector(s_val);
					ready_o	<= '1';
				end if;
			end if;
		end if;
	end process;
	
	refresh: process (clk)
	begin
		if rising_edge(clk)then
			if state = '0' then
				s_val <= unsigned(seed_i);
			elsif state = '1' then
				s_val <= s_val_new;
			end if;
		end if;
	end process;
	
	compute: process (s_val)
	begin
		if (s_val(0) = '0') then
			s_val_new <= shift_right(s_val, 1);
		elsif (s_val(0) = '1') then
			s_val_new <= shift_right(s_val, 1) xor x"80200003";
		end if;
	end process;

end Behavioral;
