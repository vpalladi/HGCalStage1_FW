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

--! I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

--! hgc constants
use work.hgc_constants.all;

entity cluster is

  generic (
    nRows    : natural;
    nColumns : natural;
    csvLatencyFile : string := "./latency.csv"  
    );

  port (
    clk                  : in std_logic;
    rst                  : in std_logic;
    enaSeed              : in std_logic;  -- enable the seed writing 
    seedingFlaggedWordIn : in hgcFlaggedWord := HGCFLAGGEDWORD_NULL;
    delayedFlaggedWordIn : in hgcFlaggedWord := HGCFLAGGEDWORD_NULL;

    -- occupancy I/O
    occupancy         : inout std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));
    occupancyComputed : in std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));
    readyToCompute    : out std_logic := '0';
    computed          : in  std_logic := '0';

    -- send 
    send     : in std_logic;
    
    -- outputs
    readyToAcquire : out std_logic := '0';
    readyToSend    : out std_logic := '0';

    sent           : out std_logic;
    flaggedWordOut : out hgcFlaggedWord := HGCFLAGGEDWORD_NULL

    );

end entity cluster;


architecture arch_1 of cluster is

    -- fsm
  type fsm is (fsm_waitingSeed, fsm_waitingEndOfFrame, fsm_acquiringWords, fsm_waitingComputing, fsm_waitingSend, fsm_sending, fsm_sent, fsm_resetting);
  signal state : fsm;
  signal state_1 : fsm;

  -- occupancy computed 
  signal occupancyComputed_internal : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));

  -- flaggedWord in and flaggedWordSeed
  signal flaggedWordIn   : hgcFlaggedWord;
  signal flaggedWordIn_1 : hgcFlaggedWord;
  signal flaggedWordIn_2 : hgcFlaggedWord;
  signal flaggedWordIn_3 : hgcFlaggedWord;
  signal flaggedWordSeed : hgcFlaggedWord := HGCFLAGGEDWORD_NULL;

  -- data storage
  signal data_flaggedWordOut : hgcFlaggedWord;
  signal data_valid : std_logic;
  signal data_send : std_logic := '0';
  signal data_sent : std_logic := '0';
  signal data_we : std_logic := '0';
  signal row   : signed(6 downto 0) := (others => '0');
  signal col   : signed(6 downto 0) := (others => '0');  
  signal row_1 : signed(6 downto 0) := (others => '0');
  signal col_1 : signed(6 downto 0) := (others => '0');  

  -- internals
  signal seedAcquired : std_logic := '0';
  signal detectedEOE  : std_logic := '0';
  signal ena_occupancy : std_logic := '0';

  -- acquisition and occupancy
  signal weSeed   : std_logic := '0';
  signal weWord   : std_logic := '0';
  signal weSeed_1   : std_logic := '0';
  signal weWord_1   : std_logic := '0';
  
  
begin  -- architecture arch_1

  -----------------------------------------------------------------------------
  -- flaggedWordIn handling 
  -----------------------------------------------------------------------------
  flaggedWordIn <= seedingFlaggedWordIn when detectedEOE = '0' else
                   delayedFlaggedWordIn when detectedEOE = '1' and delayedFlaggedWordIn.bxId = flaggedWordSeed.bxId else
                   HGCFLAGGEDWORD_NULL;

  -- to ClusterData
  p_flaggedWordIn_delay: process (clk) is
  begin  -- process p_flaggedWordInDelay
    if rising_edge(clk) then
      flaggedWordIn_1 <= flaggedWordIn;
      flaggedWordIn_2 <= flaggedWordIn_1;
      flaggedWordIn_3 <= flaggedWordIn_2;
    end if;
  end process p_flaggedWordIn_delay;

  p_compute_EdgeDetection: entity work.EdgeDetection
    port map (
      clk    => clk,
      input  => computed,
      output => ena_occupancy
      );

  
  -----------------------------------------------------------------------------
  -- outputs
  -----------------------------------------------------------------------------
  --  flaggedWordOut <= data_flaggedWordOut when data_valid = '1' and occupancyComputed_internal( to_integer(unsigned(row)), to_integer(unsigned(col)) ) = '1' else
  flaggedWordOut <= data_flaggedWordOut when data_valid = '1' else
                    HGCFLAGGEDWORD_NULL;

  readyToAcquire <= '1' when state = fsm_waitingSeed or state = fsm_waitingEndOfFrame or state = fsm_acquiringWords else
                    '0';

  readyToCompute <= '1' when state = fsm_waitingComputing else '0';
  

  readyToSend <= '1' when state = fsm_waitingSend else
                 '0';

  sent <= '1' when state = fsm_sent else
          '0';
  
  
  -------------------------------------------------------------------------------
  -- acquiring data and seeds
  -------------------------------------------------------------------------------

  -- detect EOE
  p_EOE: process (clk) is
  begin  -- process p_EOE
    if rising_edge(clk) then

      -- EOE
      if rst = '0' or state = fsm_sent then
        detectedEOE <= '0';
      elsif flaggedWordIn_3.word.EOE = '1' and flaggedWordIn_3.bxId = flaggedWordSeed.bxId and enaSeed = '0' then
        detectedEOE <= '1';
      else
        detectedEOE <= detectedEOE;
      end if;
      
    end if;
  end process p_EOE;

  
  -- wright eneable seed and word, seed acquired flagged word seed we
  p_we: process (clk) is
  begin  -- process p_we
    if rising_edge(clk) then
      
      -- seed
      if rst = '0' or state = fsm_sent then
        flaggedWordSeed <= HGCFLAGGEDWORD_NULL;
        seedAcquired    <= '0';
        weSeed          <= '0';
        weWord          <= '0';
      elsif flaggedWordIn.seedFlag = '1' and enaSeed = '1' and detectedEOE = '0' then
        flaggedWordSeed <= flaggedWordIn;
        seedAcquired    <= '1';
        weSeed          <= '1';
        weWord          <= '0';
      elsif flaggedWordIn.dataFlag = '1' and flaggedWordIn.word.valid = '1' and detectedEOE = '1' then
        flaggedWordSeed <= flaggedWordSeed;
        seedAcquired    <= seedAcquired;
        weSeed          <= '0';
        weWord          <= '1';
      else
        flaggedWordSeed <= flaggedWordSeed;
        seedAcquired    <= seedAcquired;
        weSeed          <= '0';
        weWord          <= '0';
      end if;

      weSeed_1 <= weSeed;
      weWord_1 <= weWord;
      
    end if;
  end process p_we;

  
  -- acquire seed or data
  p_acquisition : process (clk) is
    variable nbits : integer := 6;
    
    variable seed_row : unsigned(nbits-1 downto 0) := (others => '0');
    variable seed_col : unsigned(nbits-1 downto 0) := (others => '0');
    variable data_row : unsigned(nbits-1 downto 0) := (others => '0');
    variable data_col : unsigned(nbits-1 downto 0) := (others => '0');
    variable clu_row  : std_logic_vector(nbits downto 0)     := (others => '0');
    variable clu_col  : std_logic_vector(nbits downto 0)     := (others => '0');
  begin

    if rising_edge(clk) then

      -- addressing the rows
      if weSeed = '1' then  -- seed is placed in the cluster's centre

        --
        --  WAFERS' NAMING:
        --
        --    001  011  101
        --      000  010  100 
        --

        if flaggedWordIn_1.word.address.wafer = "000" then
          seed_row := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          seed_col := to_unsigned(0  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "001" then                                             
          seed_row := to_unsigned(16 + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          seed_col := to_unsigned(4  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "010" then                                             
          seed_row := to_unsigned(4  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          seed_col := to_unsigned(4  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "011" then                                             
          seed_row := to_unsigned(12 + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          seed_col := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "100" then                                             
          seed_row := to_unsigned(0  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          seed_col := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "101" then                                             
          seed_row := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          seed_col := to_unsigned(12 + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        end if;                                                                                            
                                                                                                           
        row <= to_signed( ( nRows   -1 )/2 , nbits+1 );                                    
        col <= to_signed( ( nColumns-1 )/2 , nbits+1 );                                    
                                                                                                           
      elsif weWord = '1' then                                                                              
                                                                                                           
        if    flaggedWordIn_1.word.address.wafer = "000" then                                              
          data_row := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          data_col := to_unsigned(0  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "001" then                                             
          data_row := to_unsigned(16 + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          data_col := to_unsigned(4  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "010" then                                             
          data_row := to_unsigned(4  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          data_col := to_unsigned(4  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "011" then                                             
          data_row := to_unsigned(12 + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          data_col := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "100" then                                             
          data_row := to_unsigned(0  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          data_col := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        elsif flaggedWordIn_1.word.address.wafer = "101" then                                             
          data_row := to_unsigned(8  + to_integer( unsigned(flaggedWordIn_1.word.address.row) ), nbits) ;
          data_col := to_unsigned(12 + to_integer( unsigned(flaggedWordIn_1.word.address.col) ), nbits) ;
        end if;

        row <= to_signed( to_integer(data_row) - to_integer(seed_row) + ( nRows   -1 )/2 , nbits+1 );          
        col <= to_signed( to_integer(data_col) - to_integer(seed_col) + ( nColumns-1 )/2 , nbits+1 );

      else

        row <= to_signed(-1, nbits+1);
        col <= to_signed(-1, nbits+1);
        
      end if;

--      row <= clu_row ;  
--      col <= clu_col ;
      
--      if  ( to_integer( signed(clu_row) ) > -1 and to_integer( signed(clu_row) ) < nRows ) and ( to_integer( signed(clu_col) ) > -1 and to_integer( signed(clu_col) ) < nColumns ) then
--        row <= clu_row(2 downto 0) ;  
--        col <= clu_col(2 downto 0) ;
--        
--      else
--        col <= std_logic_vector( to_signed( ( nRows   -1 )/2 , 3) );
--        row <= std_logic_vector( to_signed( ( nRows   -1 )/2 , 3) );
--      end if;

    end if;
  end process p_acquisition;

  
  -- occupancy MAP
  p_occupancy: process (clk) is
    variable clu_row  : integer   := 0;
    variable clu_col  : integer   := 0;
  begin 
    if rising_edge(clk) then

      clu_row := to_integer(row);
      clu_col := to_integer(col); 
      
      -- loop to we the correct row
      --l_rows : for irow in 0 to nRows-1 loop
      if (weSeed_1 = '1' or weWord_1 = '1') and (state_1 = fsm_waitingSeed or state_1 = fsm_acquiringWords) then
        if flaggedWordIn_2.word.valid = '1' then
          if clu_row > -1 and clu_row < nRows then
            if clu_col > -1 and clu_col < nColumns then
              data_we <= '1';
              occupancy(clu_row, clu_col) <= '1';
            else
              data_we <= '0'; 
            end if;
          else
            data_we <= '0';
          end if;
        else
          data_we <= '0';
        end if;
      elsif state_1 = fsm_resetting then
        data_we <= '0';
        l_rows : for irow in 0 to nRows-1 loop
          l_cols : for icol in 0 to nColumns-1 loop
            occupancy(irow, icol) <= '0';
          end loop l_cols;
        end loop l_rows;
      else
        data_we <= '0';
      end if;

      row_1 <= row;
      col_1 <= col;
      
      --end loop l_rows;
    end if;
  end process p_occupancy;


  -----------------------------------------------------------------------------
  -- Data storage
  -----------------------------------------------------------------------------
  data_send <= '1' when send = '1' else '0';

  p_occupancy_computed: process (clk) is
  begin  -- process p_occupancy_computed
    if rising_edge(clk) then

      if rst = '0' then
        occupancyComputed_internal <= (others => (others => '0'));
      elsif ena_occupancy = '1' then
        occupancyComputed_internal <= occupancyComputed;
      else
        occupancyComputed_internal <= occupancyComputed_internal;
      end if;

    end if;   
  end process p_occupancy_computed;
  
  e_cluster_data : entity work.cluster_data
    generic map (
      nRows    => nRows,
      nColumns => nColumns
      )
    port map (
      clk            => clk,
      rst            => rst,
      we             => data_we,
      row            => std_logic_vector( row_1(2 downto 0) ),
      col            => std_logic_vector( col_1(2 downto 0) ),
      flaggedWordIn  => flaggedWordIn_3,
      send           => data_send,
      occupancy      => occupancyComputed_internal,
      sent           => data_sent,
      flaggedWordOut => data_flaggedWordOut,
      dataValid      => data_valid
      );

  
  -----------------------------------------------------------------------------
  -- FSM
  -----------------------------------------------------------------------------
  process_fsm : process (clk) is
    variable row_rd_addr : integer := 0;
  begin
    if rising_edge(clk) then

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
          if flaggedWordIn_3.bxId = flaggedWordSeed.bxId and flaggedWordIn_3.word.EOE = '1' then
            state <= fsm_waitingComputing;
          elsif rst = '0' then
            state <= fsm_resetting;
          else
            state <= state;
          end if;
        -- computing
        when fsm_waitingComputing =>
          if ena_occupancy = '1' then
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
          if data_sent = '1' then
            state <= fsm_sent;
          elsif rst = '0' then
            state <= fsm_resetting;
          else
            state       <= state;
          end if;
        -- sent 
        when fsm_sent =>
          state <= fsm_resetting;
        when fsm_resetting =>
          state <= fsm_waitingSeed;
      end case;

      state_1 <= state;
      
    end if;
  end process process_fsm;


  
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- TXT IO
  -----------------------------------------------------------------------------
  g_for_simulation_ONLY: if not FOR_SYNTHESIS generate

    -- output to csv file
    p_output: process (clk) is

      variable clk_counter : integer := 0;

      file out_csv : text open append_mode is csvLatencyFile;
      variable L : line;
      variable sAcquired : integer := 0;
      variable beginComputing : integer := 0;
      variable endComputing : integer := 0;
      variable beginSend : integer := 0;
      variable endSend : integer := 0;
    
    begin  -- process p_output

      if rising_edge(clk) then

        if state = fsm_resetting then
          
          write( L, sAcquired );
          write( L, string' (",") );
          write( L, beginComputing );
          write( L, string' (",") );
          write( L, endComputing );
          write( L, string' (",") );
          write( L, beginSend );
          write( L, string' (",") );
          write( L, endSend );
          writeline( out_csv, L );
          
          sAcquired := 0;
          beginComputing := 0;
          endComputing := 0;
          beginSend := 0;
          endSend := 0;

        else
          
          if sAcquired = 0 and state = fsm_waitingEndOfFrame then
            sAcquired := clk_counter;
          end if; 

          if beginComputing = 0 and state = fsm_waitingComputing then
            beginComputing := clk_counter;
          end if; 

          if endComputing = 0 and state = fsm_waitingSend then
            endComputing := clk_counter;
          end if;

          if beginSend = 0 and state = fsm_sending then
            beginSend := clk_counter;
          end if;

          if endSend = 0 and state = fsm_sent then
            endSend := clk_counter;
          end if;

        end if;   

        clk_counter := clk_counter + 1;

      end if;
      
    end process p_output;
    
    -- wr to std output the occupancy and occupancy_computed
  process_writeOutput : process (clk) is
    variable panel_row : integer   := 0;
    variable panel_col : integer   := 0;
    variable L        : line;
    variable printed  : std_logic := '0';
    variable printedO : std_logic := '0';
  begin
    if rising_edge(clk) then
      if state = fsm_sending and printed = '0' then
        printed := '1';

        -----------------------------------------------------------------------
        -- computed occupancy 
        -----------------------------------------------------------------------
        WRITE(L, string' ("*** OCCUPANCY MAP*** "));
        WRITELINE(OUTPUT, L);

        WRITE(L, string' ("  "));
        for icol in nColumns-1 downto 0 loop
          --WRITE(L, (icol + to_integer(unsigned(flaggedWordSeed.word.address.col)) - (nColumns-1)/2));
          WRITE( L, (icol) );
          WRITE( L, string' (" ") );
        end loop;
        WRITELINE(OUTPUT, L);

        for irow in nRows-1 downto 0  loop
          --WRITE(L, (irow + to_integer(unsigned(flaggedWordSeed.word.address.row)) - (nRows-1)/2));
          WRITE( L, (irow) );
          WRITE( L, string' (" ") );
          for icol in nColumns-1 downto 0 loop
            --WRITE(L, occupancy(irow, icol));
            WRITE( L, occupancy(irow, icol) );
            WRITE( L, string' (" ") );
          end loop;
          WRITELINE(OUTPUT, L);

        end loop;

        -----------------------------------------------------------------------
        -- computed occupancy 
        -----------------------------------------------------------------------
        WRITE(L, string' ("*** OCCUPANCY COM*** "));
        WRITELINE(OUTPUT, L);

        WRITE(L, string' ("  "));
        for icol in nColumns-1 downto 0 loop
          --WRITE(L, (icol + to_integer(unsigned(flaggedWordSeed.word.address.col)) - (nColumns-1)/2));
          WRITE( L, (icol) );
          WRITE( L, string' (" ") );
        end loop;
        WRITELINE(OUTPUT, L);

        for irow in nRows-1 downto 0  loop
          --WRITE(L, (irow + to_integer(unsigned(flaggedWordSeed.word.address.row)) - (nRows-1)/2));
          WRITE( L, (irow) );
          WRITE( L, string' (" ") );
          for icol in nColumns-1 downto 0 loop
            --WRITE(L, occupancy(irow, icol));
            WRITE( L, occupancyComputed_internal(irow, icol) );
            WRITE( L, string' (" ") );
          end loop;
          WRITELINE(OUTPUT, L);

        end loop;

        
--      elsif state = fsm_sending and printed = '1' and printedO = '0' then
--        printedO := '1';
--        WRITE(L, string' ("*** OCCUPANCY ROW*** "));
--        WRITELINE(OUTPUT, L);
--
--        WRITE(L, string' ("  "));
--        for icol in nColumns-1 downto 0 loop
--          --WRITE(L, (icol + to_integer(unsigned(flaggedWordSeed.word.address.col)) - (nColumns-1)/2));
--          WRITE( L, (icol) );
--          WRITE( L, string' (" ") );
--        end loop;
--        WRITELINE(OUTPUT, L);
--
--        for irow in nRows-1 downto 0  loop
--          --WRITE(L, (irow + to_integer(unsigned(flaggedWordSeed.word.address.row)) - (nRows-1)/2));
--          WRITE( L, (irow) );
--          WRITE( L, string' (" ") );
--          for icol in nColumns-1 downto 0 loop
--            --WRITE(L, occupancy(irow, icol));
--            WRITE( L, occupancy(irow, icol) );
--            WRITE( L, string' (" ") );
--          end loop;
--          WRITELINE(OUTPUT, L);
--        end loop;
        
      end if;

    end if;
  end process process_writeOutput;
  
  end generate g_for_simulation_ONLY;
  -----------------------------------------------------------------------------
  -- END TXTIO
  -----------------------------------------------------------------------------

end architecture arch_1;

