--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using IPbus
use work.ipbus.all;

--! MP7 datatypes
use work.mp7_data_types.all;

--! HGC datatypes
use work.hgc_data_types.all;


entity inputStage is
  
  generic (
    tmux : natural := 18
    );
  port (
    rst      : in std_logic;
    clkLink  : in std_logic;            --! the links clock
    clk      : in std_logic;            --! The algorithm clock
    linksIn  : in ldata(71 downto 0) := (others => LWORD_NULL);

    dValid : out std_logic;
    output : out std_logic_vector(127 downto 0)
    );
end entity inputStage;


architecture arch_inputStage of inputStage is

  type std_logic_vector_array is array (natural range <>) of std_logic_vector(127 downto 0);

  signal bx_cnt               : natural   := 0;
  signal first_fe_rena    : std_logic := '0';
  
  -- front end
  signal fe_rena          : std_logic_array(tmux-1 downto 0) := (others => '0');
  signal fe_dataOut       : std_logic_vector_array(tmux-1 downto 0);
  signal fe_dataValid     : std_logic_array(tmux-1 downto 0);  
  signal fe_ready_to_send : std_logic_array(tmux-1 downto 0) := (others => '0');

  signal fe_bx_almost_end            : std_logic_array(tmux-1 downto 0) := (others => '0');
  signal fe_bx_end            : std_logic_array(tmux-1 downto 0) := (others => '0');
  signal fe_current_bx        : integer range tmux-1 downto 0    := 0;
  signal fe_next_bx           : integer range tmux-1 downto 0    := 1;

begin  -- architecture arch_inputStage

  -----------------------------------------------------------------------------
  -- output signals
  -----------------------------------------------------------------------------
  output <= fe_dataOut(fe_current_bx) when fe_dataValid(fe_current_bx) = '1'
            else (others => '0');
  dValid <= '1' when fe_dataValid(fe_current_bx) = '1'
            else '0';
  
  -----------------------------------------------------------------------------
  -- generate the input block (input links are grouped in 4 to generate the
  -- 128b word from the Stage-2)
  -----------------------------------------------------------------------------
  g_inputBlock : for i_bx in 0 to tmux-1 generate
    e_LinksConcentrator : entity work.LinksConcentrator
      port map (
        wclk    => clkLink,
        rclk    => clk,
        rst     => rst,
        linkIn0 => linksIn(4*i_bx),
        linkIn1 => linksIn(1 + 4*i_bx),
        linkIn2 => linksIn(2 + 4*i_bx),
        linkIn3 => linksIn(3 + 4*i_bx),

        rena        => fe_rena(i_bx),
        bxAlmostEnd => fe_bx_almost_end(i_bx),
        bxEnd       => fe_bx_end(i_bx),
        readyToSend => fe_ready_to_send(i_bx),
        dataValid   => fe_dataValid(i_bx),
        dataOut     => fe_dataOut(i_bx)
        );
  end generate g_inputBlock;

  -- asserted when the fist rena is asserted
  p_first_fe_rena: process (clk) is
  begin  
    if rising_edge(clk) then

      if rst = '1' then
        first_fe_rena <= '0';
      elsif fe_rena(0) = '1' and first_fe_rena <= '0' then
        first_fe_rena <= '1';
      end if;
      
    end if;
  end process p_first_fe_rena;
  
  -- bx counter and current_bx increment
  p_bx_cnt : process (clk) is
  begin  -- process p_bx_cnt
    if rising_edge(clk) then

      if rst = '1' then
        bx_cnt <= 0;
        fe_current_bx <= 0;
        fe_next_bx <= 1;
      elsif fe_bx_end(fe_current_bx) = '1' then
        bx_cnt <= bx_cnt + 1;

        if fe_current_bx = tmux-1 then
          fe_current_bx <= 0;
        else
          fe_current_bx <= fe_current_bx + 1;
        end if;
        
        if fe_next_bx = tmux-1 then
          fe_next_bx <= 0;
        else
          fe_next_bx <= fe_next_bx + 1;
        end if;
      end if;

    end if;
  end process p_bx_cnt;

  -- rena the correct group of links 
  p_rena : process (clk) is
    variable rena_sent : std_logic := '0';
    variable rena_next_sent : std_logic := '0';
  begin  -- process p_rena
    if rising_edge(clk) then

      if rst = '1' then

        rena_sent              := '0';
        rena_next_sent              := '0';
        for_reset_fe_rena : for i in 0 to tmux-1 loop
          fe_rena(i) <= '0';
        end loop; 
        
      elsif first_fe_rena = '0' then
        
        if fe_ready_to_send(fe_current_bx) = '1' then --and rena_sent = '0' then --need to wait that next link is ready to send
          rena_sent              := '1';
          fe_rena(fe_current_bx) <= '1';
        end if;
        
      else

        if rena_sent = '1' or rena_next_sent = '1' then
          rena_sent              := '0';
          rena_next_sent              := '0';
          fe_rena(fe_current_bx) <= '0';
          fe_rena(fe_next_bx) <= '0';
        elsif fe_bx_almost_end(fe_current_bx) = '1' and fe_ready_to_send(fe_next_bx) = '1' and rena_next_sent = '0' then --need to wait that next link is ready to send
          rena_next_sent              := '1';
          fe_rena(fe_next_bx) <= '1';
        elsif rena_next_sent = '1' and fe_bx_end(fe_next_bx) = '1' then
          rena_next_sent := '0';
        else
          fe_rena(fe_next_bx) <= '0';
        end if;
        
      end if;
      
    end if;
  end process p_rena;

end architecture arch_inputStage;
  
