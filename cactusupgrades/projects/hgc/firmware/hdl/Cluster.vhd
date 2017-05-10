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
    nRows    : integer := 5;
    nColumns : integer := 5
    );

  port (
    clk                  : in std_logic;
    rst                  : in std_logic;
    enaSeed              : in std_logic;  -- enable the seed writing 
    seedingFlaggedWordIn : in hgcFlaggedWord;
    delayedFlaggedWordIn : in hgcFlaggedWord;
    --seedWordIn    : in hgcFlaggedWord;

    --weSeed : in std_logic;
    --weWord : in std_logic;
    --EOE    : in std_logic := '0';
    send : in std_logic;

    --seedAcquired   : out std_logic := '0';
    readyToAcquire : out std_logic := '0';
    readyToSend    : out std_logic := '0';

    sent           : out std_logic;
    --dataValid : out std_logic;
    flaggedWordOut : out hgcFlaggedWord
--    flaggedDataOut : out hgcFlaggedData(nRows-1 downto 0)

    );

end entity cluster;


architecture arch_1 of cluster is

  -- occupancy matrix
  signal occupancy         : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));
  signal occupancyComputed : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));

  -- flaggedWord in and flaggedSeedWord
  signal flaggedWordIn   : hgcFlaggedWord;
  signal flaggedSeedWord : hgcFlaggedWord := HGCFLAGGEDWORD_NULL;

  -- types
  type std_logic_array is array (nRows-1 downto 0) of std_logic;
  type std_logic_vector_array is array (nRows-1 downto 0) of std_logic_vector(2 downto 0);

  signal row_flaggedDataOut : hgcFlaggedData(nRows-1 downto 0);
  signal row_flaggedWordIn  : hgcFlaggedData(nRows-1 downto 0);  -- := (others => HGCWORDDATA_NULL);
  signal row_we             : std_logic_array;
  signal row_send           : std_logic_array;
  signal row_sent           : std_logic_array;
  signal row_flaggedWordOut : hgcFlaggedData(nRows-1 downto 0);  -- := (others => HGCWORDDATA_NULL);
  signal row_dataValid      : std_logic_array;
  --signal row_dataValid      : std_logic_vector(nRows-1 downto 0); 

  -- internals
  signal seedAcquired : std_logic := '0';
  signal detectedEOE  : std_logic := '0';

  -- computing
  signal compute    : std_logic := '0';
  signal computed   : std_logic := '0';
  signal comp_clean : std_logic := '0';

  -- fsm
  type fsm is (fsm_waitingSeed, fsm_waitingEndOfFrame, fsm_acquiringWords, fsm_computing, fsm_waitingSend, fsm_sending, fsm_sent, fsm_resetting);
  signal state : fsm;

  -- reset singals
  signal resetDone : std_logic := '0';

begin  -- architecture arch_1


  -----------------------------------------------------------------------------
  -- flaggedWordIn handling
  -----------------------------------------------------------------------------

  flaggedWordIn <= seedingFlaggedWordIn when detectedEOE = '0' else
                   delayedFlaggedWordIn when detectedEOE = '1' and delayedFlaggedWordIn.bxId = flaggedSeedWord.bxId else
                   HGCFLAGGEDWORD_NULL;


  -------------------------------------------------------------------------------
  -- acquire the seed 
  -------------------------------------------------------------------------------

  p_acquisition : process (clk) is
    variable row_addr : integer   := 0;
    variable col_addr : integer   := 0;
    variable weSeed   : std_logic := '0';
    variable weWord   : std_logic := '0';
  begin

    if rising_edge(clk) then

      -- EOE
      if rst = '0' or state = fsm_sent then
        detectedEOE <= '0';
      elsif flaggedWordIn.word.EOE = '1' and flaggedWordIn.bxId = flaggedSeedWord.bxId and enaSeed = '0' then
        detectedEOE <= '1';
      else
        detectedEOE <= detectedEOE;
      end if;

      -- seed
      if rst = '0' or state = fsm_sent then
        flaggedSeedWord <= HGCFLAGGEDWORD_NULL;
        seedAcquired    <= '0';
        weSeed          := '0';
        weWord          := '0';
      elsif flaggedWordIn.seedFlag = '1' and enaSeed = '1' and detectedEOE = '0' then
        flaggedSeedWord <= flaggedWordIn;
        seedAcquired    <= '1';
        weSeed          := '1';
        weWord          := '0';
      elsif flaggedWordIn.dataFlag = '1' and flaggedWordIn.word.valid = '1' and detectedEOE = '1' then
        flaggedSeedWord <= flaggedSeedWord;
        seedAcquired    <= seedAcquired;
        weSeed          := '0';
        weWord          := '1';
      else
        flaggedSeedWord <= flaggedSeedWord;
        seedAcquired    <= seedAcquired;
        weSeed          := '0';
        weWord          := '0';
      end if;

      -- addressing the rows
      if weSeed = '1' then  -- seed is placed in the cluster's centre
        row_addr := ( nRows-1 )/2;
        col_addr := ( nColumns-1 )/2;
      elsif flaggedWordIn.word.address.wafer = "000" then
        row_addr := 4  + to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
        col_addr := 16 + to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;
      elsif flaggedWordIn.word.address.wafer = "001" then
        row_addr :=      to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
        col_addr := 8  + to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;
      elsif flaggedWordIn.word.address.wafer = "010" then
        row_addr := 8  + to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
        col_addr := 12 + to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;
      elsif flaggedWordIn.word.address.wafer = "011" then
        row_addr := 4  + to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
        col_addr := 4  + to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;
      elsif flaggedWordIn.word.address.wafer = "100" then
        row_addr := 12 + to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
        col_addr := 8  + to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;
      elsif flaggedWordIn.word.address.wafer = "101" then
        row_addr := 8  + to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
        col_addr :=      to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;

--        row_addr := to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
--        col_addr := to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;
--      else
--        row_addr := to_integer( unsigned(flaggedWordIn.word.address.row) ) - to_integer( unsigned(flaggedSeedWord.word.address.row) ) + ( nRows-1 )/2;
--        col_addr := to_integer( unsigned(flaggedWordIn.word.address.col) ) - to_integer( unsigned(flaggedSeedWord.word.address.col) ) + ( nColumns-1 )/2;
      end if;

      -- loop to we the correct row
      l_rows : for irow in 0 to nRows-1 loop
        if (weSeed = '1' or weWord = '1') and (state = fsm_waitingSeed or state = fsm_acquiringWords) then
          if flaggedWordIn.word.valid = '1' and row_addr = irow then
            row_we(irow) <= '1';
            if row_addr > -1 and row_addr < nRows then
              if col_addr > -1 and col_addr < nColumns then
                occupancy(row_addr, col_addr) <= '1';
              end if;
            end if;
          else
            row_we(irow) <= '0';
          end if;
        elsif state = fsm_resetting then
          row_we(irow) <= '0';
          l_cols : for icol in 0 to nColumns-1 loop
            occupancy(irow, icol) <= '0';
          end loop l_cols;
        else
          row_we(irow) <= '0';
        end if;
      end loop l_rows;

    end if;

  end process p_acquisition;


  -----------------------------------------------------------------------------
  -- Data storage
  -----------------------------------------------------------------------------

  e_cluster_data: entity work.cluster_data
    port map (
      clk            => clk,
      rst            => rst,
      flaggedWordIn  => flaggedWordIn,
      send           => send,
      sent           => sent,
      flaggedWordOut => flaggedWordOut
    );

--  g_rows : for i_row in 0 to nRows-1 generate
--
--    cluster_row : entity work.clusterRow
--      generic map (
--        nColumns => nColumns
--        )
--      port map (
--        clk               => clk,
--        flaggedSeedWordIn => flaggedSeedWord,
--        flaggedWordIn     => flaggedWordIn,
--        we                => row_we(i_row),
--        send              => row_send(i_row),
--        sent              => row_sent(i_row),
--        flaggedWordOut    => row_flaggedDataOut(i_row),
--        dataValid         => row_dataValid(i_row)
--       -- sent          => row_sent(i_row)
--        );

--    flaggedWordOut <= row_flaggedDataOut(i_row) when row_dataValid(i_row) = '1' else
--                      HGCFLAGGEDWORD_NULL;
    
    --row_flaggedWordOut(i_row).word.address.row <= std_logic_vector(to_signed(i_row, 4) + signed(flaggedSeedWord.word.address.row) - to_signed((nRows-1)/2, 4));
    --flaggedDataOut(i_row) <= row_flaggedWordOut(i_row);
    --row_flaggedWordIn(i_row) <= flaggedWordIn;
    --dataValid <= row_dataValid(i_row);

--  end generate g_rows;

  --  with row_dataValid select
  --    flaggedWordOut <=
  --    row_flaggedDataOut(0) when "00001",
  --    row_flaggedDataOut(1) when "00010",
  --    row_flaggedDataOut(2) when "00100",
  --    row_flaggedDataOut(3) when "01000",
  --    row_flaggedDataOut(4) when "10000",
  --    HGCFLAGGEDWORD_NULL               when others;
  
  flaggedWordOut <= row_flaggedDataOut(0) when row_dataValid(0) = '1' else
                    row_flaggedDataOut(1) when row_dataValid(1) = '1' else
                    row_flaggedDataOut(2) when row_dataValid(2) = '1' else
                    row_flaggedDataOut(3) when row_dataValid(3) = '1' else
                    row_flaggedDataOut(4) when row_dataValid(4) = '1' else
                    HGCFLAGGEDWORD_NULL;
  -- send signal to single rows
  row_send(0) <= '1' when send = '1' else '0';
  l_send_rows : for i_row in 1 to nRows-1 generate
    row_send(i_row) <= '1' when row_sent(i_row-1) = '1' else '0';
  end generate;

  -----------------------------------------------------------------------------
  -- addressing the rows
  -----------------------------------------------------------------------------

--  process_addressing : process (clk) is
--    variable row_addr : integer := 0;
--    variable col_addr : integer := 0;
--    variable L                : line;
----    variable weSeed : std_logic := '0';
----    variable weData : std_logic := '0';     
--  begin
--    if rising_edge(clk) then
--
--      -- is data or is seed 
----      if flaggedWordIn.seedFlag = '1' and enaSeed = '1' then
----        weSeed := '1';
----        weWord := '0';
----      elsif flaggedWordIn.dataFlag = '1' and flaggedWordIn.word.valid = '1' then
----        weSeed := '0';
----        weWord := '1';
----      else
----        weSeed := '0';
----        weWord := '0';
----      end if;
--
--      -- where to write
--      if weSeed = '1' then
--        row_addr := (nRows-1)/2;
--        col_addr := (nColumns-1)/2;
--      else
--        row_addr := to_integer(unsigned(flaggedWordIn.word.address.row))-to_integer(unsigned(flaggedSeedWord.word.address.row)) + (nRows-1)/2;
--        col_addr := to_integer(unsigned(flaggedWordIn.word.address.col))-to_integer(unsigned(flaggedSeedWord.word.address.col)) + (nColumns-1)/2;
--      end if;
--
----      WRITE(L, to_integer(unsigned(flaggedWordIn.address.row)) );
----      WRITE(L, string' (" ") );
----      WRITE(L, to_integer(unsigned(flaggedWordIn.address.col)) );
----      WRITE(L, string' (" - ") );
----      WRITE(L, to_integer(unsigned(flaggedSeedWord.address.row)) );
----      WRITE(L, string' (" ") );
----      WRITE(L, to_integer(unsigned(flaggedSeedWord.address.col)) );
----      WRITE(L, string' (" - ") );
----            
----      WRITE(L, row_addr );
----      WRITE(L, string' (" ") );
----      WRITE(L, col_addr );
----      WRITELINE(OUTPUT, L);
--
--      -- addressing rows
--      we_rows : for irow in 0 to nRows-1 loop
--        if (weSeed = '1' or weWord = '1') and (state = fsm_waitingSeed or state = fsm_acquiringWords) then
--          if flaggedWordIn.word.valid = '1' and row_addr = irow then
--            row_we(irow) <= '1';
--            if row_addr > -1 and row_addr < nRows then
--              if col_addr > -1 and col_addr < nColumns then
--                occupancy(row_addr, col_addr) <= '1';
--              end if;  
--            end if;
--          else
--            row_we(irow) <= '0';
--          end if;
--        else
--          row_we(irow) <= '0';
--        end if;
--      end loop we_rows;
--
--    end if;
--  end process process_addressing;


  -----------------------------------------------------------------------------
  -- computing 
  -----------------------------------------------------------------------------

  e_computeClu : entity work.computeClu
    generic map (
      nRows    => nRows,
      nColumns => nColumns
      )
    port map (
      clk          => clk,
      clean        => comp_clean,
      compute      => compute,
      occupancyMap => occupancy,
      computed     => computed,
      cluster      => occupancyComputed
      );


  -----------------------------------------------------------------------------
  -- txt output 
  -----------------------------------------------------------------------------

  process_writeOutput : process (clk) is
    variable row_addr : integer   := 0;
    variable col_addr : integer   := 0;
    variable L        : line;
    variable printed  : std_logic := '0';
  begin
    if rising_edge(clk) then
      if state = fsm_sending and printed = '0' then
        printed := '1';
        WRITE(L, string' ("*** OCCUPANCY *** "));
        WRITELINE(OUTPUT, L);

        WRITE(L, string' ("  "));
        for icol in 0 to nColumns-1 loop
          WRITE(L, (icol + to_integer(unsigned(flaggedSeedWord.word.address.col)) - (nColumns-1)/2));
          WRITE(L, string' (" "));
        end loop;
        WRITELINE(OUTPUT, L);

        for irow in nRows-1 downto 0 loop
          WRITE(L, (irow + to_integer(unsigned(flaggedSeedWord.word.address.row)) - (nRows-1)/2));
          WRITE(L, string' (" "));
          for icol in 0 to nColumns-1 loop
            --WRITE(L, occupancy(irow, icol));
            WRITE(L, occupancyComputed(irow, icol));
            WRITE(L, string' (" "));
          end loop;
          WRITELINE(OUTPUT, L);
        end loop;

      end if;

    end if;
  end process process_writeOutput;

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
          if seedAcquired = '1' then
            state <= fsm_waitingEndOfFrame;
          elsif rst = '0' then
            state <= fsm_waitingSeed;
          else
            state <= state;
          end if;
        -- waintg end of frame
        when fsm_waitingEndOfFrame =>
          if detectedEOE = '1' then
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
          if flaggedWordIn.bxId = flaggedSeedWord.bxId and flaggedWordIn.word.EOE = '1' then
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
--        when fsm_sending =>
--          if row_rd_addr = nColumns-1 then
--            state <= fsm_sent;
--          elsif rst = '0' then
--            state <= fsm_resetting;
--          else
--            row_rd_addr := row_rd_addr+1;
--            state       <= state;
--          end if;

        when fsm_sending =>
          if row_sent(nRows-1) = '1' then
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

  readyToSend <= '1' when state = fsm_waitingSend else
                 '0';

  sent <= '1' when state = fsm_sent else
          '0';

  readyToAcquire <= '1' when state = fsm_waitingSeed or state = fsm_waitingEndOfFrame or state = fsm_acquiringWords else
                    '0';
  compute <= '1' when state = fsm_computing else
             '0';
  comp_clean <= '1' when state = fsm_resetting else
                '0';

end architecture arch_1;

