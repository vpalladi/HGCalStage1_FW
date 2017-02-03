--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

--! @brief An entity providing a TestbenchFMBus
--! @details Detailed description
ENTITY TestbenchFMBus IS
END TestbenchFMBus;

ARCHITECTURE Behavioral OF TestbenchFMBus IS
  SIGNAL clk                                                         : STD_LOGIC := '1';
  SIGNAL BusIn , BusOut                                              : tFMBus( 0 TO 1 );
  SIGNAL BusClk                                                      : STD_LOGIC                       := '1';
--SIGNAL BusInfoSpace : tFMBusInfoSpace( 0 TO 1 );

  SIGNAL MasterInstructionIn                                         : tFMBusState                     := Ignore;
  SIGNAL MasterInstructionValid , MasterDone                         : BOOLEAN                         := FALSE;
  SIGNAL MasterDataIn , MasterDataOut                                : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL MasterDataValid                                             : BOOLEAN                         := FALSE;
  SIGNAL MasterReady                                                 : BOOLEAN                         := FALSE;

  SIGNAL SlaveAddrOut1 , SlaveAddrOut2                               : STD_LOGIC_VECTOR( 11 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL SlaveDataIn1 , SlaveDataOut1 , SlaveDataIn2 , SlaveDataOut2 : STD_LOGIC_VECTOR( 8 DOWNTO 0 )  := ( OTHERS => '0' );
  SIGNAL SlaveWriteEn1 , SlaveWriteEn2                               : STD_LOGIC                       := '0';
BEGIN

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    clk <= NOT clk AFTER 10 ns;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  FMBusMasterInstance : ENTITY work.FMBusMaster
  PORT MAP(
    Clk              => clk ,
    BusIn            => BusIn ,
    BusOut           => BusOut ,
    BusClk           => BusClk ,
    InstructionIn    => MasterInstructionIn ,
    InstructionValid => MasterInstructionValid ,
    DataIn           => MasterDataIn ,
    DataInValid      => MasterDataValid ,
    DataOut          => MasterDataOut ,
    Ready            => MasterReady ,
    Done             => MasterDone
  );
-- ---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
  FMBusDecoderInstance1 : ENTITY work.FMBusRamDecoder
  GENERIC MAP(
    BusName => "Decoder1"
  )
  PORT MAP(
    BusIn     => BusIn( 0 TO 0 ) ,
    BusOut    => BusOut( 0 TO 0 ) ,
    BusClk    => BusClk ,
    AddrOut   => SlaveAddrOut1 ,
    DataOut   => SlaveDataOut1 ,
    DataValid => SlaveWriteEn1 ,
    DataIn    => SlaveDataIn1
  );
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
  FMBusDecoderInstance2 : ENTITY work.FMBusRamDecoder
  GENERIC MAP(
    BusName => "Decoder2"
  )
  PORT MAP(
    BusIn     => BusIn( 1 TO 1 ) ,
    BusOut    => BusOut( 1 TO 1 ) ,
    BusClk    => BusClk ,
    AddrOut   => SlaveAddrOut2 ,
    DataOut   => SlaveDataOut2 ,
    DataValid => SlaveWriteEn2 ,
    DataIn    => SlaveDataIn2
  );
---------------------------------------------------------------------------------

---- ---------------------------------------------------------------------------------
-- FMBusDecoderInstance1 : ENTITY work.FMBusRegDecoder
-- GENERIC MAP(
-- BusName => "Decoder1"
-- )
-- PORT MAP(
-- BusIn => BusIn( 0 TO 0 ) ,
-- BusOut => BusOut( 0 TO 0 ) ,
-- BusClk => BusClk
-- DataOut => SlaveDataOut1 ,
-- DataValid => SlaveWriteEn1 ,
-- DataIn => SlaveDataIn1
-- );
---- ---------------------------------------------------------------------------------

---- ---------------------------------------------------------------------------------
-- FMBusDecoderInstance2 : ENTITY work.FMBusRegDecoder
-- GENERIC MAP(
-- BusName => "Decoder2"
-- )
-- PORT MAP(
-- BusIn => BusIn( 1 TO 1 ) ,
-- BusOut => BusOut( 1 TO 1 ) ,
-- BusClk => BusClk
-- DataOut => SlaveDataOut2 ,
-- DataValid => SlaveWriteEn2 ,
-- DataIn => SlaveDataIn2
-- );
---- ---------------------------------------------------------------------------------


END Behavioral;
