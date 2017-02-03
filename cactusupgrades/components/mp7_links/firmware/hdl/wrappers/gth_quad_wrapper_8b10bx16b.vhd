library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

use work.package_links.all;
use work.package_utilities.all;


entity gth_quad_wrapper_8b10bx16b is
generic
(
    -- Simulation attributes
    SIMULATION                      : integer   := 0;           -- Set to 1 for simulation
    SIM_GTRESET_SPEEDUP             : string    := "FALSE";     -- Set to "true" to speed up sim reset
    -- Configuration
    STABLE_CLOCK_PERIOD             : integer   := 32;          -- Period of the stable clock driving this state-machine, unit is [ns] 
    LINE_RATE                       : real		  := 5.0;        -- gb/s
    REFERENCE_CLOCK_RATE            : real      := 125.0;         -- mhz
    PRBS_MODE                       : string    := "PRBS-7";
    -- Placement information
    X_LOC                           : integer 	:= 0;
    Y_LOC                           : integer 	:= 0
);
port
(
    -- Common signals
    soft_reset_in                      : in   std_logic;
    refclk_in                          : in   std_logic;
    drpclk_in                          : in   std_logic;
    sysclk_in                          : in   std_logic;
    qplllock_out                       : out   std_logic;
		
		-- Common dynamic reconfiguration port
		common_drp_address_in  	: in  std_logic_vector(7 downto 0);
		common_drp_data_in  		: in  std_logic_vector(15 downto 0);
		common_drp_data_out 		: out std_logic_vector(15 downto 0);
		common_drp_enable_in   	: in  std_logic;
		common_drp_ready_out    : out std_logic;
		common_drp_write_in    	: in  std_logic;
		
    -- Channel signals
    rxusrclk_out                       : out  std_logic_vector(3 downto 0);
    txusrclk_out                       : out  std_logic_vector(3 downto 0);
    rxusrrst_out                       : out  std_logic_vector(3 downto 0);
    txusrrst_out                       : out  std_logic_vector(3 downto 0);
		
		-- Serdes links
    rxn_in                             : in   std_logic_vector(3 downto 0);
    rxp_in                             : in   std_logic_vector(3 downto 0);
    txn_out                            : out  std_logic_vector(3 downto 0);
    txp_out                            : out  std_logic_vector(3 downto 0);
		
		-- Channel dynamic reconfiguration ports
    chan_drp_address_in		: in type_drp_addr_array(3 downto 0);
    chan_drp_data_in			: in type_drp_data_array(3 downto 0);
    chan_drp_data_out			: out type_drp_data_array(3 downto 0);
    chan_drp_enable_in		: in std_logic_vector(3 downto 0);
    chan_drp_ready_out		: out std_logic_vector(3 downto 0);
    chan_drp_write_in			: in std_logic_vector(3 downto 0);
		
		-- State machines that control MGT Tx / Rx initialisation
    tx_fsm_reset_in                    : in   std_logic_vector(3 downto 0);
    rx_fsm_reset_in                    : in   std_logic_vector(3 downto 0);
    tx_fsm_reset_done_out              : out   std_logic_vector(3 downto 0);
    rx_fsm_reset_done_out              : out   std_logic_vector(3 downto 0);
		
		-- Misc
		loopback_in                        : in type_loopback_array(3 downto 0);
		
		-- Tx signals
    txoutclk_out                       : out  std_logic_vector(3 downto 0);
    txpolarity_in                      : in  std_logic_vector(3 downto 0);
    txdata_in                          : in type_16b_data_array(3 downto 0);
    txcharisk_in                       : in type_16b_charisk_array(3 downto 0);
		
		-- Rx signals 
    rx_comma_det_out                   : out   std_logic_vector(3 downto 0);
    rxpolarity_in                      : in  std_logic_vector(3 downto 0);
    rxcdrlock_out                      : out  std_logic_vector(3 downto 0);
    rxdata_out                         : out type_16b_data_array(3 downto 0);
    rxcharisk_out                      : out type_16b_charisk_array(3 downto 0);
    rxchariscomma_out                  : out type_16b_chariscomma_array(3 downto 0);
    rxbyteisaligned_out                : out std_logic_vector(3 downto 0);
    rxpcommaalignen_in                : in std_logic_vector(3 downto 0);
    rxmcommaalignen_in                : in std_logic_vector(3 downto 0)
);



end gth_quad_wrapper_8b10bx16b;





library generic_sync;
use generic_sync.definitions.all;

library virtex_7_transceivers_common;
use virtex_7_transceivers_common.types.all;
use virtex_7_transceivers_common.definitions.all;

library virtex_7_transceivers_gth;
use virtex_7_transceivers_gth.definitions.all;



architecture RTL of gth_quad_wrapper_8b10bx16b is

  constant DLY : time := 1 ns;

  signal    txoutclk, rxoutclk     : std_logic_vector(3 downto 0); 
  signal    txusrclk, rxusrclk     : std_logic_vector(3 downto 0); 
  signal    txusrclk2, rxusrclk2   : std_logic_vector(3 downto 0); 

  attribute keep: string;  
  attribute keep of txusrclk : signal is "true";
  attribute keep of txusrclk2 : signal is "true";
  attribute keep of rxusrclk : signal is "true";
  attribute keep of rxusrclk2 : signal is "true";
  
	attribute keep of txoutclk : signal is "true";
  attribute keep of rxoutclk : signal is "true";

  signal loopback_mode : array_gt_loopback(3 downto 0);
  
  signal rx_char_is_k  : array_gt_16b_k_data(3 downto 0);
  signal rx_data       : array_gt_16b_data(3 downto 0);
  
  signal tx_char_is_k  : array_gt_16b_k_data(3 downto 0);
  signal tx_data       : array_gt_16b_data(3 downto 0);

  signal tx_fsm_reset_done, rx_fsm_reset_done   : std_logic_vector(3 downto 0); 
  signal tx_fsm_reset_n_done, rx_fsm_reset_n_done   : std_logic_vector(3 downto 0); 
	
  signal chan_drp_address_local  : array_gt_drp_addr(3 downto 0);
  signal chan_drp_data_in_local  : array_gt_drp_data(3 downto 0);
  signal chan_drp_data_out_local : array_gt_drp_data(3 downto 0);
	signal chan_drp_clk : std_logic_vector(3 downto 0);

begin


  ----------------------------------------------------------------------------
  -- Move tx/rx fsm done signals into usrclk domain for use as reset
  ----------------------------------------------------------------------------

  rx_fsm_reset_n_done <= not rx_fsm_reset_done;
  tx_fsm_reset_n_done <= not tx_fsm_reset_done;

  usrrst: for i in 0 to 3 generate
  
    rxusrrst_sync: async_pulse_sync
    port map(
        async_pulse_in => rx_fsm_reset_n_done(i),
        sync_clk_in => rxusrclk(i),
        sync_pulse_out => rxusrrst_out(i),
        sync_pulse_sgl_clk_out => open);
        
    txusrrst_sync: async_pulse_sync
    port map(
        async_pulse_in => tx_fsm_reset_n_done(i),
        sync_clk_in => txusrclk(i),
        sync_pulse_out => txusrrst_out(i),
        sync_pulse_sgl_clk_out => open);      
      
  end generate;
	
	chan_drp_clk <= (others => drpclk_in);
  
  ----------------------------------------------------------------------------
  -- Clocking
  ----------------------------------------------------------------------------

  gt0_usrclk_source : entity work.usrclk_source
  port map
  (
    refclk_in                   =>      refclk_in,  
    txusrclk_out                =>      txusrclk,
    txusrclk2_out               =>      txusrclk2,
    txoutclk_in                 =>      txoutclk,
    rxusrclk_out                =>      rxusrclk,
    rxusrclk2_out               =>      rxusrclk2,
    rxoutclk_in                 =>      rxoutclk
  );

  ----------------------------------------------------------------------------
  -- Quad
  ----------------------------------------------------------------------------

  gth_quad_i : gth_quad_8b10bx16b
  generic map (
    STABLE_REFERENCE_CLOCK_PERIOD => STABLE_CLOCK_PERIOD,          
    LINE_RATE            => LINE_RATE,
    REFERENCE_CLOCK_RATE => REFERENCE_CLOCK_RATE,
    PRBS_MODE => PRBS_MODE,
    -- Simulation attributes
    WRAPPER_SIM_GTRESET_SPEEDUP => SIM_GTRESET_SPEEDUP,
    X_LOC                       => X_LOC,
    Y_LOC                       => Y_LOC
    )
  port map (
    stable_reference_clk => sysclk_in,

    -- FSM control
    tx_fsm_reset      => tx_fsm_reset_in,
    rx_fsm_reset      => rx_fsm_reset_in,
    tx_fsm_reset_done => tx_fsm_reset_done,
    rx_fsm_reset_done => rx_fsm_reset_done,

    -- GT blocks
    tx_power_down => "0000",
    rx_power_down => "0000",
    tx_use_qpll_n_cpll => "1111",
    rx_use_qpll_n_cpll => "1111",
    loopback_mode => loopback_mode,
    prbs_enable   => "0000",
    prbs_error    => open,

    -- Statistics
    rx_stability_count_reset => "0000",
    rx_stability_count       => open,
    rx_recclk_stable         => open,

    -- DRP port
    drp_address  => chan_drp_address_local,
    drp_clk      => chan_drp_clk,
    drp_data_in  => chan_drp_data_in_local,
    drp_data_out => chan_drp_data_out_local,
    drp_enable   => chan_drp_enable_in,
    drp_ready    => chan_drp_ready_out,
    drp_write    => chan_drp_write_in,

    -- Receive Ports - 8b10b Decoder
    rx_char_is_k => rx_char_is_k,

    -- Receive Ports - Comma Detection and Alignment
    rx_byte_is_aligned => rxbyteisaligned_out,
    rx_byte_realign    => open,
    rx_comma_det       => rx_comma_det_out,

    rx_data      => rx_data,
    rx_out_clk   => rxoutclk,
    rx_usr_clk   => rxusrclk,
    rx_usr_clk_2 => rxusrclk2,

    -- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR
    rxn => rxn_in,
    rxp => rxp_in,

    -- Receive Ports - RX PLL Ports
    rx_reset_done => open,

    -- Transmit Ports - 8b10b Encoder Control Ports
    tx_char_is_k => tx_char_is_k,
    tx_data      => tx_data,

    tx_out_clk   => txoutclk,
    tx_usr_clk   => txusrclk,
    tx_usr_clk_2 => txusrclk2,

    -- Transmit Ports - TX Driver and OOB signaling
    txn => txn_out,
    txp => txp_out,

    -- Transmit Ports - TX PLL Ports
    tx_reset_done => open,

    -- CPLL status
    cpll_ref_clk_lost => open,
    cpll_locked => open,

    -- Common DRP
    common_drp_address  => common_drp_address_in,
    common_drp_clk      => drpclk_in,
    common_drp_data_in  => common_drp_data_in,
    common_drp_data_out => common_drp_data_out,
    common_drp_enable   => common_drp_enable_in,
    common_drp_ready    => common_drp_ready_out,
    common_drp_write    => common_drp_write_in,

    -- Common Block - Ref Clock Ports
    ref_clk         => refclk_in,

    -- Common Block - QPLL Ports
    qpll_ref_clk_lost => open,
    qpll_locked       => qplllock_out
    );

  ----------------------------------------------------------------------------
  -- Outputs
  ----------------------------------------------------------------------------

  txusrclk_out <= txusrclk;
  rxusrclk_out <= rxusrclk;
  txoutclk_out <= txoutclk;
  tx_fsm_reset_done_out <= tx_fsm_reset_done;
  rx_fsm_reset_done_out <= rx_fsm_reset_done;

  ----------------------------------------------------------------------------
  -- Missing signal...
  ----------------------------------------------------------------------------

  rxcdrlock_out <= "1111";  -- Need to add CDR lock or use DRP
  
  ----------------------------------------------------------------------------
  -- Map types...
  ----------------------------------------------------------------------------
  
  map_types: for i in 0 to 3 generate
	
    -- Incoming
    loopback_mode(i) <= loopback_in(i);
    tx_char_is_k(i) <= txcharisk_in(i);
    tx_data(i) <= txdata_in(i);
		chan_drp_address_local(i) <= chan_drp_address_in(i);
		chan_drp_data_in_local(i) <= chan_drp_data_in(i);
		
    -- Outgoing
    rxcharisk_out(i) <= rx_char_is_k(i);
    rxdata_out(i) <= rx_data(i);
		chan_drp_data_out(i) <= chan_drp_data_out_local(i);

    -- Not available at present on JJ transceiver
    rxchariscomma_out <= (others => "00");
		
  end generate;

end RTL;
