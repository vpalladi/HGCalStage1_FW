--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! @brief An entity providing a PipelineOffsetRAM
--! @details Detailed description
ENTITY PipelineOffsetRAM IS
  GENERIC(
           width : INTEGER := 0;
           depth : INTEGER := 0
         );
  PORT(
        clk          : IN STD_LOGIC                             := '0' ; --! The algorithm clock
        data_in_pos  : IN STD_LOGIC_VECTOR( width-1 DOWNTO 0 )  := ( OTHERS => '0' );
        data_in_neg  : IN STD_LOGIC_VECTOR( width-1 DOWNTO 0 )  := ( OTHERS => '0' );
        valid_in     : IN BOOLEAN                               := FALSE;
        data_out_pos : OUT STD_LOGIC_VECTOR( width-1 DOWNTO 0 ) := ( OTHERS => '0' );
        data_out_neg : OUT STD_LOGIC_VECTOR( width-1 DOWNTO 0 ) := ( OTHERS => '0' )
      );
END ENTITY PipelineOffsetRAM;

--! @brief Architecture definition for entity PipelineOffsetRAM
--! @details Detailed description
ARCHITECTURE behavioral OF PipelineOffsetRAM IS
  SIGNAL write_data_pos , read_data_pos : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL write_data_neg , read_data_neg : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL write_addr , read_addr         : STD_LOGIC_VECTOR( 5 DOWNTO 0 )  := ( OTHERS => '0' );
  SIGNAL source                         : INTEGER RANGE 0 TO 3            := 0;

  SIGNAL valid_clk                      : BOOLEAN                         := FALSE;

BEGIN

  write_data_pos( width-1 DOWNTO 0 ) <= data_in_pos;
  write_data_neg( width-1 DOWNTO 0 ) <= data_in_neg;

  RAM_pos : ENTITY work.PipeOffsetDPRAM
  PORT MAP(
    clka  => clk ,
    wea   => "1" ,
    addra => write_addr ,
    dina  => write_data_pos ,
    clkb  => clk ,
    addrb => read_addr ,
    doutb => read_data_pos
  );

  RAM_neg : ENTITY work.PipeOffsetDPRAM
  PORT MAP(
    clka  => clk ,
    wea   => "1" ,
    addra => write_addr ,
    dina  => write_data_neg ,
    clkb  => clk ,
    addrb => read_addr ,
    doutb => read_data_neg
  );

  PROCESS( CLK )
    VARIABLE counter : INTEGER RANGE 0 TO 64 := 0;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

      valid_clk <= valid_in;

      IF valid_in AND NOT valid_clk THEN
        counter := 1;
      ELSE
        counter := ( counter + 1 ) MOD 64;
      END IF;

      IF NOT valid_in THEN
        write_addr <= STD_LOGIC_VECTOR( TO_UNSIGNED( 0 , 6 ) );
      ELSE
        write_addr <= STD_LOGIC_VECTOR( TO_UNSIGNED( counter , 6 ) );
      END IF;

      IF counter  <= depth + 3 THEN
        read_addr <= STD_LOGIC_VECTOR( TO_UNSIGNED( ( depth + 3 ) -counter , 6 ) );
      ELSE
        read_addr <= STD_LOGIC_VECTOR( TO_UNSIGNED( counter - ( depth + 4 ) , 6 ) );
      END IF;

      IF counter < depth THEN
        data_out_pos <= ( OTHERS => '0' );
        data_out_neg <= ( OTHERS => '0' );
      ELSIF counter = depth THEN
        data_out_pos <= data_in_neg( width-1 DOWNTO 0 );
        data_out_neg <= data_in_pos( width-1 DOWNTO 0 );
      ELSIF counter < 2 * depth THEN
        data_out_pos <= read_data_neg( width-1 DOWNTO 0 );
        data_out_neg <= read_data_pos( width-1 DOWNTO 0 );
      ELSE
        data_out_pos <= read_data_pos( width-1 DOWNTO 0 );
        data_out_neg <= read_data_neg( width-1 DOWNTO 0 );
      END IF;
    END IF;
  END PROCESS;


END ARCHITECTURE behavioral;
