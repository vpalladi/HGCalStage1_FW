--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! MP7 datatypes
use work.mp7_data_types.all;
--! MP7 datatypes
use work.hgc_data_types.all;


entity outputStage is

  generic (
    nFifosOut : natural  := 18
    );
  port (
    clk   : in std_logic;
    rst   : in std_logic;

    dValid : in std_logic;
    dIn : in std_logic_vector( 127 downto 0 );

    readyToTransmit : out std_logic;
    
    rena : in std_logic;
    linksOut : out ldata(71 downto 0) := (others => LWORD_NULL)
    );
  
end entity outputStage;


architecture arch_outputStage of outputStage is

  type std_logic_vector_array is array (natural range <>) of std_logic_vector(127 downto 0);
  
  signal current_fifo : natural range 0 to nFifosOut-1  := 0;
  signal previous_fifo : natural range 0 to nFifosOut-1  := 0;
  signal dIn_1 : std_logic_vector( 127 downto 0 );
  signal dIn_2 : std_logic_vector( 127 downto 0 );
  signal first_event_acquired : std_logic := '0';
  
  -- fifos
  signal fifo_wr_en  : std_logic_array(nFifosOut-1 downto 0);
  signal fifo_rd_en  : std_logic_array(nFifosOut-1 downto 0);
  signal fifo_dout   : std_logic_vector_array(nFifosOut-1 downto 0);
  signal fifo_full   : std_logic_array(nFifosOut-1 downto 0);
  signal fifo_empty  : std_logic_array(nFifosOut-1 downto 0);

  
begin

  -----------------------------------------------------------------------------
  -- external signals 
  -----------------------------------------------------------------------------
  readyToTransmit <= '1' when fifo_empty(nFifosOut-1) = '0'
                     else '0';
  
  g_linksOut: for i_fifo in 0 to nFifosOut-1 generate

    linksOut(i_fifo*4  ).data <= fifo_dout(i_fifo)(127 downto 96);
    linksOut(i_fifo*4+1).data <= fifo_dout(i_fifo)(95  downto 64);
    linksOut(i_fifo*4+2).data <= fifo_dout(i_fifo)(63  downto 32);
    linksOut(i_fifo*4+3).data <= fifo_dout(i_fifo)(31  downto 0 );
    
  end generate g_linksOut;

  
  -----------------------------------------------------------------------------
  -- delay dIn andcurrent_fifo
  -----------------------------------------------------------------------------
  p_delay_dIn: process (clk) is
  begin  -- process p_delay_dIn
    if rising_edge(clk) then

      dIn_1 <= dIn;
      dIn_2 <= dIn_1;
      
    end if;
  end process p_delay_dIn;


  -----------------------------------------------------------------------------
  -- advancing to the next fifo
  -----------------------------------------------------------------------------
  p_next_fifo : process (clk) is
  begin  -- process p_next_fifo
    if rising_edge(clk) then

      if rst = '1' then
        current_fifo <= 0;
        previous_fifo <= nFifosOut-1;
      elsif dValid = '1' then
        if current_fifo = nFifosOut-1 then
          current_fifo <= 0;
        else
          current_fifo <= current_fifo + 1;
        end if;
        previous_fifo <= current_fifo;
      end if;
        
    end if;
  end process p_next_fifo;


  -----------------------------------------------------------------------------
  -- buffer fifos
  -----------------------------------------------------------------------------  

  -- write to fifos
  p_fifo_wena: process (clk) is
  begin  -- process p_fifo_wena
    if rising_edge(clk) then

      if rst = '1' then
        for ilink in 0 to nFifosOut-1 loop
          fifo_wr_en(ilink) <= '0';
        end loop;  -- ilink
      elsif dValid = '1' then
        fifo_wr_en(current_fifo) <= '1';
        fifo_wr_en(previous_fifo) <= '0';      
      end if;
      
    end if;
  end process p_fifo_wena;
 
  -- generate fifos
  g_fifos: for i_fifo in 0 to nFifosOut-1 generate

    fifo_rd_en(i_fifo) <= rena;
    
    fifo_output_stage_1: entity work.fifo_output_stage
      port map (
        rst    => rst,
        wr_clk => clk,
        rd_clk => clk,
        din    => dIn_2,
        wr_en  => fifo_wr_en(i_fifo),
        rd_en  => fifo_rd_en(i_fifo),
        dout   => fifo_dout(i_fifo),
        full   => fifo_full(i_fifo),
        empty  => fifo_empty(i_fifo)
        );
    
  end generate g_fifos;

  
end architecture arch_outputStage;


