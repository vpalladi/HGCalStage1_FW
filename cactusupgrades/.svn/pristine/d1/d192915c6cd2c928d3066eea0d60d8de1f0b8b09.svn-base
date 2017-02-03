--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

--! @brief An entity providing a LinksIn
--! @details Detailed description
ENTITY LinksIn IS
  PORT(
    clk          : IN STD_LOGIC                            := '0' ; --! The algorithm clock
    linksIn      : IN ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
    towerPipeOut : OUT tTowerPipe ; --! A pipe of tTower objects passing out the tower's
    BusIn        : IN tFMBus;
    BusOut       : OUT tFMBus;
    BusClk       : IN STD_LOGIC := '0'
  );
END LinksIn;

--! @brief Architecture definition for entity LinksIn
--! @details Detailed description
ARCHITECTURE behavioral OF LinksIn IS
  SIGNAL realTowerInEtaPhi , dummyTowerInEtaPhi : tTowerInEtaPhi                  := cEmptyTowerInEtaPhi;
  SIGNAL towerInEtaPhi                          : tTowerInEtaPhi                  := cEmptyTowerInEtaPhi;
  SIGNAL LinkMask                               : STD_LOGIC_VECTOR( 71 DOWNTO 0 ) := ( OTHERS => '0' );
BEGIN

-- --------------------------------------------------
  LinkMaskInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName     => "LinkMask" ,
    Registering => 2
  )
  PORT MAP(
    DataOut => LinkMask ,
    BusIn   => BusIn ,
    BusOut  => BusOut ,
    BusClk  => BusClk
  );
-- --------------------------------------------------


  quad_gen       : FOR j IN( cNumberOfQuadsIn-1 ) DOWNTO 0 GENERATE
    link_gen     : FOR k IN 3 DOWNTO 0 GENERATE
      CONSTANT i : NATURAL := ( j * 4 ) + k;
      CONSTANT l : NATURAL := ( j * 4 ) + ( ( k + 1 ) MOD 4 );
    BEGIN
        TowerFormerInstance : ENTITY work.TowerFormer
          PORT MAP(
            clk       => clk ,
            DataValid => linksIn( i ) .valid ,
            linksIn   => linksIn( i ) .data( 15 DOWNTO 0 ) ,
            towerOut  => realTowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) ) -- ( half barrel )( phi )
          );
        TowerFormerInstance2 : ENTITY work.TowerFormer
          PORT MAP(
            clk       => clk ,
            DataValid => linksIn( i ) .valid ,
            linksIn   => linksIn( i ) .data( 31 DOWNTO 16 ) ,
            towerOut  => realTowerInEtaPhi( i MOD 2 )( ( 2 * ( i / 2 ) ) + 1 ) -- ( half barrel )( phi )
          );

-- Create Dummy Tower( 0 energy , data valid from neighbouring link in quad mod 4 )
        DummyTowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) ) .DataValid     <= realTowerInEtaPhi( l MOD 2 )( 2 * ( l / 2 ) ) .DataValid;
        DummyTowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) + 1 ) .DataValid <= realTowerInEtaPhi( l MOD 2 )( 2 * ( l / 2 ) + 1 ) .DataValid;

        TowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) )                     <= DummyTowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) ) WHEN LinkMask( i ) = '1'
                                                    ELSE realTowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) );

        TowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) + 1 ) <= DummyTowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) + 1 ) WHEN LinkMask( i ) = '1'
                                                    ELSE realTowerInEtaPhi( i MOD 2 )( 2 * ( i / 2 ) + 1 );


    END GENERATE link_gen;
  END GENERATE quad_gen;


  TowerPipeInstance : ENTITY work.TowerPipe
  PORT MAP(
    clk       => clk ,
    towersIn  => towerInEtaPhi ,
    towerPipe => towerPipeOut
  );

END ARCHITECTURE behavioral;
