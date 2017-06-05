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

entity computeClu is
  generic (
    nRows    : integer := 5;
    nColumns : integer := 5
    );
  port (
    clk          : in std_logic;
    clean        : in std_logic;
    compute      : in std_logic;
    occupancyMap : in std_logic_matrix(0 to nRows-1, 0 to nColumns-1);
    computed     : out std_logic;
    cluster      : inout std_logic_matrix(0 to nRows-1, 0 to nColumns-1)
  );

end entity computeClu;

architecture arch_computeClu of computeClu is

  type fsm is (fsm_waitingCompute, fsm_computing, fsm_computed, fsm_clean);
  signal state : fsm := fsm_clean;

  -- mask to apply
  signal mask : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));

  -- computed signals 
  signal internal_computed : std_logic := '0';
  
begin  -- architecture computeClu

  -----------------------------------------------------------------------------
  -- assignements
  -----------------------------------------------------------------------------
  computed <= internal_computed;

  
  -----------------------------------------------------------------------------
  -- fsm
  -----------------------------------------------------------------------------
  process_fsm: process (clk) is
  begin  -- process process_fsm
    if rising_edge(clk) then

      case state is
        when fsm_waitingCompute =>
          if compute = '1' then
            state <= fsm_computing;
          else
            state <= state;
          end if;
        when fsm_computing =>
          if internal_computed = '1' then
            state <= fsm_computed;
          else
            state <= state;
          end if;
        when fsm_computed =>
          if clean = '1' then
            state <= fsm_clean;
          else
            state <= state;
          end if; 
        when fsm_clean =>
          state <= fsm_waitingCompute;
      end case;
      
    end if;
  end process process_fsm;


  -----------------------------------------------------------------------------
  -- computing
  -----------------------------------------------------------------------------

  --mask((nRows-1)/2,(nColumns-1)/2) <= '1';
  
  process_computing: process (clk) is
    variable iteration : integer := 0;
    
  begin
    if rising_edge(clk) then
      
      if state <= fsm_waitingCompute then

        cluster((nRows-1)/2, (nColumns-1)/2) <= '1';
        
        mask((nRows-1)/2,  (nColumns-1)/2+1) <= '1';
        mask((nRows-1)/2,  (nColumns-1)/2-1) <= '1';
        mask((nRows-1)/2+1,(nColumns-1)/2)   <= '1';
        mask((nRows-1)/2-1,(nColumns-1)/2)   <= '1';
        mask((nRows-1)/2+1,(nColumns-1)/2+1) <= '1';
        mask((nRows-1)/2-1,(nColumns-1)/2-1) <= '1';
                  
      elsif state = fsm_computing then

        for irow in 0 to nRows-1 loop
          for icol in 0 to nColumns-1 loop
            if occupancyMap(irow,icol) = '1' and mask(irow,icol) = '1' then

              cluster(irow,icol) <= '1'; 
              
              if icol < nColumns-1 then
                mask(irow,icol+1)   <= '1';
              end if;
              if icol > 0 then
                mask(irow,icol-1)   <= '1';
              end if;
              if irow<nRows-1 then
                mask(irow+1,icol)   <= '1';
              end if;
              if irow > 0 then
                mask(irow-1,icol)   <= '1';
              end if;
              if irow<nRows-1 and icol<nColumns-1 then
                mask(irow+1,icol+1) <= '1';
              end if;
              if irow>0 and icol>0 then
                mask(irow-1,icol-1) <= '1';
              end if;
            end if;
          end loop;  -- icol
        end loop;  -- irow
        
        iteration := iteration + 1;

      elsif state = fsm_clean then
        internal_computed <= '0';
                
        iteration := 0;
        for irow in 0 to nRows-1 loop
          for icol in 0 to nColumns-1 loop
            mask(irow,icol)   <= '0';
            cluster(irow,icol)   <= '0';
          end loop;  -- icol
        end loop;  -- irow
      end if;

      if iteration = 4 then
        internal_computed <= '1';
      end if;
      
    end if;
  end process process_computing;

end architecture arch_computeClu;
