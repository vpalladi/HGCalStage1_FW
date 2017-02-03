--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
--use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;

--! hgc data types
use work.hgc_data_types.all;

-------------------------------------------------------------------------------
-- temporary
-------------------------------------------------------------------------------
-- I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;



entity cluster is

  generic (
    nRows    : integer := 7;
    nColumns : integer := 7
    );

  port (
    clk           : in std_logic;
    rst           : in std_logic;
    flaggedWordIn : in hgcFlaggedWord;
    flaggedWordInForSeeding : in hgcFlaggedWord;

    weSeed : in std_logic;
    weWord : in std_logic;
    EOE    : in std_logic := '0';
    send   : in std_logic;

    seedAcquired   : out std_logic := '0';
    readyToAcquire : out std_logic := '0';

    sent           : out std_logic;
    --dataValid : out std_logic;
    flaggedDataOut : out hgcFlaggedData(nRows-1 downto 0) 

    );

end entity cluster;


architecture arch_1 of cluster is

  -- occupancy matrix
  signal clusterOccupancy : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));
  signal clusterComputed : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));
  
  -- delayed signals
  signal internalFlaggedWordIn   : hgcFlaggedWord;
  signal internalFlaggedWordIn_1 : hgcFlaggedWord;

  -- types
  type std_logic_array is array (nRows-1 downto 0) of std_logic;
  type std_logic_vector_array is array (nRows-1 downto 0) of std_logic_vector(2 downto 0);

  signal row_flaggedWordIn  : hgcFlaggedData(nRows-1 downto 0);  -- := (others => HGCWORDDATA_NULL);
  signal row_we             : std_logic_array;
  signal row_send           : std_logic_array;
  signal row_flaggedWordOut : hgcFlaggedData(nRows-1 downto 0);  -- := (others => HGCWORDDATA_NULL);
  signal row_dataValid      : std_logic_array;
--  signal row_sent       : std_logic_array;

  signal flaggedSeedWord : hgcFlaggedWord := HGCFLAGGEDWORD_NULL;

  -- internals
  --signal internalSent         : std_logic := '0';
  signal internalSeedAcquired : std_logic := '0';

  -- computing
  signal compute  : std_logic := '0';
  signal computed : std_logic := '0';
  signal comp_clean : std_logic := '0';
  -- fsm
  type fsm is (fsm_waitingSeed, fsm_waitingEndOfFrame, fsm_acquiringWords, fsm_computing, fsm_waitingSend, fsm_sending, fsm_sent, fsm_resetting);
  signal state : fsm;

  -- reset singals
  signal resetDone : std_logic := '0';
  
begin  -- architecture arch_1

  process_delay : process (clk) is
  begin
    if rising_edge(clk) then            -- rising clock edge
      internalFlaggedWordIn_1 <= internalFlaggedWordIn;
    end if;
  end process process_delay;

  
  -----------------------------------------------------------------------------
  -- ports
  -----------------------------------------------------------------------------
  seedAcquired <= internalSeedAcquired;


  -------------------------------------------------------------------------------
  -- chose the right input 
  -------------------------------------------------------------------------------
  internalFlaggedWordIn <= flaggedWordIn when internalSeedAcquired = '1' else
                           flaggedWordInForSeeding; 
  
  -----------------------------------------------------------------------------
  -- Matrix rows generate
  -----------------------------------------------------------------------------

  generates_rows : for i_row in nRows-1 to 0 generate

    inst_cluster_row : entity work.clusterRow
      generic map (
        nColumns => nColumns
        )
      port map (
        clk               => clk,
        flaggedSeedWordIn => flaggedSeedWord,
        flaggedWordIn     => row_flaggedWordIn(i_row),
        we                => row_we(i_row),
        send              => row_send(i_row),
        flaggedWordOut    => row_flaggedWordOut(i_row)
       --dataValid         => row_dataValid(i_row),
--        sent          => row_sent(i_row)
        );

    row_flaggedWordOut(i_row).address.row <= std_logic_vector(to_signed(i_row, 4) + signed(flaggedSeedWord.address.row) - to_signed((nRows-1)/2, 4));
    flaggedDataOut(i_row)                 <= row_flaggedWordOut(i_row);
    row_flaggedWordIn(i_row)              <= internalFlaggedWordIn_1;
    row_send(i_row)                       <= '1' when state = fsm_sending else
                                             '0';
    --dataValid <= row_dataValid(i_row);

  end generate generates_rows;


  -------------------------------------------------------------------------------
  -- acquire the seed 
  -------------------------------------------------------------------------------

  flaggedSeedWord <= flaggedWordIn when weSeed = '1' else
                     HGCFLAGGEDWORD_NULL when state = fsm_sent else
                     flaggedSeedWord;
  internalSeedAcquired <= '1' when weSeed = '1' else
                          '0' when state = fsm_sent else
                          internalSeedAcquired;


  -----------------------------------------------------------------------------
  -- addressing the rows
  -----------------------------------------------------------------------------

  process_addressing : process (clk) is
    variable integer_row_addr : integer := 0;
    variable integer_col_addr : integer := 0;
    variable L               : line;
  begin
    if rising_edge(clk) then

      if weSeed = '1' then
        integer_row_addr := (nRows-1)/2;
        integer_col_addr := (nColumns-1)/2;
      else
        integer_row_addr := to_integer(unsigned(flaggedWordIn.address.row))-to_integer(unsigned(flaggedSeedWord.address.row)) + (nRows-1)/2;
        integer_col_addr := to_integer(unsigned(flaggedWordIn.address.col))-to_integer(unsigned(flaggedSeedWord.address.col)) + (nColumns-1)/2;
      end if;

--      WRITE(L, to_integer(unsigned(flaggedWordIn.address.row)) );
--      WRITE(L, string' (" ") );
--      WRITE(L, to_integer(unsigned(flaggedWordIn.address.col)) );
--      WRITE(L, string' (" - ") );
--      WRITE(L, to_integer(unsigned(flaggedSeedWord.address.row)) );
--      WRITE(L, string' (" ") );
--      WRITE(L, to_integer(unsigned(flaggedSeedWord.address.col)) );
--      WRITE(L, string' (" - ") );
--            
--      WRITE(L, integer_row_addr );
--      WRITE(L, string' (" ") );
--      WRITE(L, integer_col_addr );
--      WRITELINE(OUTPUT, L);

      
      we_rows : for irow in 0 to nRows-1 loop
        if (weSeed = '1' or weWord = '1') and (state = fsm_waitingSeed or state = fsm_acquiringWords) then
          if flaggedWordIn.valid = '1' and integer_row_addr = irow then
            row_we(irow) <= '1';
            
            if integer_row_addr > -1 and integer_row_addr < nRows then
              if integer_col_addr > -1 and integer_col_addr < nColumns then
               
                clusterOccupancy(integer_row_addr,integer_col_addr) <= '1';
              end if;
            end if;
          else
            row_we(irow) <= '0';
          end if;
        else
          row_we(irow) <= '0';
        end if;        
      end loop we_rows;

    end if;
  end process process_addressing;


  -----------------------------------------------------------------------------
  -- computing 
  -----------------------------------------------------------------------------
  computeClu_1: entity work.computeClu
    generic map (
      nRows    => nRows,
      nColumns => nColumns
      )
    port map (
      clk          => clk,
      clean        => comp_clean,
      compute      => compute,
      occupancyMap => clusterOccupancy,
      computed     => computed,
      cluster      => clusterComputed
      );


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  process_writeOutput: process (clk) is
    variable integer_row_addr : integer := 0;
    variable integer_col_addr : integer := 0;
    variable L               : line;
    variable printed : std_logic := '0';
  begin
    if rising_edge(clk) then
      if state = fsm_sending and printed = '0'  then
        printed := '1';   
        WRITE(L, string' ("*** OCCUPANCY *** "));
        WRITELINE(OUTPUT, L);   

        WRITE(L, string' ("  "));
        for icol in 0 to nColumns-1 loop
          WRITE(L, (icol + to_integer(unsigned(flaggedSeedWord.address.col)) - (nColumns-1)/2) );
          WRITE(L, string' (" ") );     
        end loop;
        WRITELINE(OUTPUT, L);   
        
        for irow in nRows-1 downto 0 loop
          WRITE(L, (irow + to_integer(unsigned(flaggedSeedWord.address.row)) - (nRows-1)/2) );
          WRITE(L, string' (" ") );
          for icol in 0 to nColumns-1 loop
--              WRITE(L, clusterOccupancy(irow, icol));
            WRITE(L, clusterComputed(irow, icol));
            WRITE(L, string' (" "));
          end loop;
          WRITELINE(OUTPUT, L);
        end loop;
      
    end if;
      
    end if;
  end process process_writeOutput;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------
  -- FSM
  -----------------------------------------------------------------------------

  process_fsm : process (clk) is
    variable row_rd_addr : integer := 0;
  begin  -- process process_fsm
    if rising_edge(clk) then            -- rising clock edge

      case state is
        -- waiting seed
        when fsm_waitingSeed =>
          row_rd_addr := 0;
          if internalSeedAcquired = '1' then
            state <= fsm_waitingEndOfFrame;
          elsif rst = '0' then
            state <= fsm_waitingSeed;
          else
            state <= state;
          end if;
        -- waintg end of frame
        when fsm_waitingEndOfFrame =>
          if weWord = '1' then
            state <= fsm_acquiringWords;
          elsif send = '1' then
            state <= fsm_sending;
          elsif rst = '0' then
            state <= fsm_resetting;
          else
            state <= state;
          end if;
        -- acquiring words
        when fsm_acquiringWords =>
          if EOE = '1' then
            state <= fsm_computing;
          elsif rst = '0' then
            state <= fsm_resetting;
          else
            state <= state;
          end if;
        -- computing
        when fsm_computing =>
          if computed = '1' then
            state <= fsm_waitingSend;
          elsif rst = '0' then
            state <= fsm_resetting;
          else
            state <= state;
          end if;
        -- waiting send
        when fsm_waitingSend =>
          if send = '1' then
            state <= fsm_sending;
          elsif rst = '0' then
            state <= fsm_resetting;
          else
            state <= state;
          end if;
        -- sending
        when fsm_sending =>
          if row_rd_addr = nColumns-1 then
            state <= fsm_sent;
          elsif rst = '0' then
            state <= fsm_resetting;
          else
            row_rd_addr := row_rd_addr+1;
            state       <= state;
          end if;
        -- sent 
        when fsm_sent =>
          state <= fsm_resetting;
        when fsm_resetting =>
          state <= fsm_waitingSeed;
      end case;

    end if;
  end process process_fsm;

  sent <= '1' when state = fsm_sent else
          '0';
  readyToAcquire <= '1' when state = fsm_waitingSeed or state = fsm_waitingEndOfFrame or state = fsm_acquiringWords else
                    '0';
  compute <= '1' when state = fsm_computing else
             '0';
  comp_clean <= '1' when state = fsm_resetting else
                '0';

end architecture arch_1;

