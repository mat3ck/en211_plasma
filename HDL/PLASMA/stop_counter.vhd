library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity stop_counter is
	generic (
		nbits 	: integer;
		nmax 	: integer
	);
	port (
		clk 		: in  std_logic;
		rst 		: in  std_logic;
		enable 		: in  std_logic;
		data 		: out std_logic_vector (nbits-1 downto 0);
		overflow 	: out std_logic
	);
end stop_counter;


architecture Behavioral of stop_counter is
	-- Signals
	signal counter 	: integer range 0 to nmax-1 := 0;

begin

	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				counter 	<= 0;
				overflow 	<= '0';
			elsif enable = '1' then
				if counter = nmax-1 then
					counter 	<= 0;
					overflow 	<= '1';
				else
					counter 	<= counter + 1;
					overflow 	<= '0';
				end if;
			else
				counter 	<= counter;
				overflow 	<= '0';
			end if;
		end if;
	end process;

	data <= std_logic_vector( to_unsigned(counter, nbits) );

end Behavioral;
