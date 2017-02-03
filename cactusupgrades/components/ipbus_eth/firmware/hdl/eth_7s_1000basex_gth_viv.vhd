-- Contains the instantiation of the Xilinx MAC & 1000baseX pcs/pma & GTP transceiver cores
--
-- Do not change signal names in here without correspondig alteration to the timing contraints file
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;
use work.emac_hostbus_decl.all;

entity eth_7s_1000basex is
	port(
		gt_clkp, gt_clkn: in std_logic;
		gt_txp, gt_txn: out std_logic;
		gt_rxp, gt_rxn: in std_logic;
		clk125_out: out std_logic;
		clk125_fr: out std_logic;
		refclk_out: out std_logic;
		rsti: in std_logic;
		locked: out std_logic;
		tx_data: in std_logic_vector(7 downto 0);
		tx_valid: in std_logic;
		tx_last: in std_logic;
		tx_error: in std_logic;
		tx_ready: out std_logic;
		rx_data: out std_logic_vector(7 downto 0);
		rx_valid: out std_logic;
		rx_last: out std_logic;
		rx_error: out std_logic;
		hostbus_in: in emac_hostbus_in := ('0', "00", "0000000000", X"00000000", '0', '0', '0');
		hostbus_out: out emac_hostbus_out
	);

end eth_7s_1000basex;

architecture rtl of eth_7s_1000basex is

    component tri_mode_eth_mac_v8_3 is
        port(
        gtx_clk                    : in  std_logic;
        glbl_rstn                  : in  std_logic;
        rx_axi_rstn                : in  std_logic;
        tx_axi_rstn                : in  std_logic;
        rx_statistics_vector       : out std_logic_vector(27 downto 0);
        rx_statistics_valid        : out std_logic;
        rx_mac_aclk                : out std_logic;
        rx_reset                   : out std_logic;
        rx_axis_mac_tdata          : out std_logic_vector(7 downto 0);
        rx_axis_mac_tvalid         : out std_logic;
        rx_axis_mac_tlast          : out std_logic;
        rx_axis_mac_tuser          : out std_logic;
        tx_ifg_delay               : in  std_logic_vector(7 downto 0);
        tx_statistics_vector       : out std_logic_vector(31 downto 0);
        tx_statistics_valid        : out std_logic;
        tx_mac_aclk                : out std_logic;
        tx_reset                   : out std_logic;
        tx_axis_mac_tdata          : in  std_logic_vector(7 downto 0);
        tx_axis_mac_tvalid         : in  std_logic;
        tx_axis_mac_tlast          : in  std_logic;
        tx_axis_mac_tuser          : in  std_logic_vector(0 downto 0);
        tx_axis_mac_tready         : out std_logic;
        pause_req                  : in  std_logic;
        pause_val                  : in  std_logic_vector(15 downto 0);
        speedis100                 : out std_logic;
        speedis10100               : out std_logic;
        gmii_txd                   : out std_logic_vector(7 downto 0);
        gmii_tx_en                 : out std_logic;
        gmii_tx_er                 : out std_logic;
        gmii_rxd                   : in  std_logic_vector(7 downto 0);
        gmii_rx_dv                 : in  std_logic;
        gmii_rx_er                 : in  std_logic;
        rx_configuration_vector    : in  std_logic_vector(79 downto 0);
        tx_configuration_vector    : in  std_logic_vector(79 downto 0)
        );
    end component;


    component gig_ethernet_pcs_pma_0_block is
        port(
        gtrefclk             : in std_logic;                     -- Very high quality 125MHz clock for GT transceiver.
        txp                  : out std_logic;                    -- Differential +ve of serial transmission from PMA to PMD.
        txn                  : out std_logic;                    -- Differential -ve of serial transmission from PMA to PMD.
        rxp                  : in std_logic;                     -- Differential +ve for serial reception from PMD to PMA.
        rxn                  : in std_logic;                     -- Differential -ve for serial reception from PMD to PMA.
        txoutclk             : out std_logic;                    -- txoutclk from GT transceiver (62.5MHz)
        rxoutclk             : out std_logic;                    -- txoutclk from GT transceiver (62.5MHz)
        resetdone            : out std_logic;                    -- The GT transceiver has completed its reset cycle
        cplllock            : out std_logic;                    -- The GT transceiver has completed its reset cycle
        mmcm_locked          : in std_logic;                     -- Locked indication from MMCM
        userclk              : in std_logic;                     -- 62.5MHz global clock.
        userclk2             : in std_logic;                     -- 125MHz global clock.
        rxuserclk              : in std_logic;                     -- 62.5MHz global clock.
        rxuserclk2             : in std_logic;                     -- 125MHz global clock.
        independent_clock_bufg : in std_logic;                   -- 200MHz independent cloc,
        pma_reset            : in std_logic;                     -- transceiver PMA reset signal
        gmii_txd             : in std_logic_vector(7 downto 0);  -- Transmit data from client MAC.
        gmii_tx_en           : in std_logic;                     -- Transmit control signal from client MAC.
        gmii_tx_er           : in std_logic;                     -- Transmit control signal from client MAC.
        gmii_rxd             : out std_logic_vector(7 downto 0); -- Received Data to client MAC.
        gmii_rx_dv           : out std_logic;                    -- Received control signal to client MAC.
        gmii_rx_er           : out std_logic;                    -- Received control signal to client MAC.
        gmii_isolate         : out std_logic;                    -- Tristate control to electrically isolate GMII.
        configuration_vector : in std_logic_vector(4 downto 0);  -- Alternative to MDIO interface.
        status_vector        : out std_logic_vector(15 downto 0); -- Core status.
        reset                : in std_logic;                     -- Asynchronous reset for entire core.
        signal_detect        : in std_logic;                      -- Input from PMD to indicate presence of optical input.
        gt0_qplloutclk_in                          : in   std_logic;
        gt0_qplloutrefclk_in                       : in   std_logic
        );
    end component;

	signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
	signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;
	signal gmii_rx_clk: std_logic;
	signal clkin, clk125, txoutclk_ub, txoutclk, clk125_ub, clk_fr: std_logic;
	signal clk62_5_ub, clk62_5, clkfb: std_logic;
	signal rstn, phy_done, mmcm_locked, locked_int: std_logic;
	signal status: std_logic_vector(15 downto 0);
	signal decoupled_clk: std_logic := '0';

begin
	
	ibuf0: IBUFDS_GTE2 port map(
		i => gt_clkp,
		ib => gt_clkn,
		o => clkin,
		ceb => '0'
	);
	
	bufg_fr: BUFG port map(
		i => clkin,
		o => clk_fr
	);
	
	refclk_out <= clkin;
	clk125_fr <= clk_fr;
	
	bufh_tx: BUFH port map(
		i => txoutclk_ub,
		o => txoutclk
	);
	
	mmcm: MMCME2_BASE
		generic map(
			CLKIN1_PERIOD => 16.0,
			CLKFBOUT_MULT_F => 16.0,
			CLKOUT1_DIVIDE => 16,
			CLKOUT2_DIVIDE => 8)
		port map(
			clkin1 => txoutclk,
			clkout1 => clk62_5_ub,
			clkout2 => clk125_ub,
			clkfbout => clkfb,
			clkfbin => clkfb,
			rst => rsti,
			pwrdwn => '0',
			locked => mmcm_locked);
	
	bufr_125: BUFH
		port map(
			i => clk125_ub,
			o => clk125
		);

	clk125_out <= clk125;

	bufr_62_5: BUFH
		port map(
			i => clk62_5_ub,
			o => clk62_5
		);

	process(clk_fr)
	begin
		if rising_edge(clk_fr) then
			locked_int <= mmcm_locked and phy_done;
		end if;
	end process;

	locked <= locked_int;
	rstn <= not (not locked_int or rsti);

	mac: tri_mode_eth_mac_v8_3
		port map(
			glbl_rstn => rstn,
			rx_axi_rstn => '1',
			tx_axi_rstn => '1',
			rx_axi_clk => clk125,
			rx_reset_out => open,
			rx_axis_mac_tdata => rx_data,
			rx_axis_mac_tvalid => rx_valid,
			rx_axis_mac_tlast => rx_last,
			rx_axis_mac_tuser => rx_error,
			rx_statistics_vector => open,
			rx_statistics_valid => open,
			tx_axi_clk => clk125,
			tx_reset_out => open,
			tx_axis_mac_tdata => tx_data,
			tx_axis_mac_tvalid => tx_valid,
			tx_axis_mac_tlast => tx_last,
			tx_axis_mac_tuser(0) => tx_error,
			tx_axis_mac_tready => tx_ready,
			tx_ifg_delay => X"00",
			tx_statistics_vector => open,
			tx_statistics_valid => open,
			pause_req => '0',
			pause_val => X"0000",
			speed_is_100 => open,
			speed_is_10_100 => open,
			gmii_txd => gmii_txd,
			gmii_tx_en => gmii_tx_en,
			gmii_tx_er => gmii_tx_er,
			gmii_rxd => gmii_rxd,
			gmii_rx_dv => gmii_rx_dv,
			gmii_rx_er => gmii_rx_er,
			rx_mac_config_vector => X"0000_0000_0000_0000_0812",
			tx_mac_config_vector => X"0000_0000_0000_0000_0012"
		);

	hostbus_out.hostrddata <= (others => '0');
	hostbus_out.hostmiimrdy <= '0';

    -- Vivado generates a CRC error if you drive the CPLLLOCKDET circuitry with
    -- the same clock used to drive the transceiver PLL.  While this makes sense
    -- if the clk is derved from the CPLL (e.g. TXOUTCLK) it is less clear is 
    -- essential if you use the clock raw from the input pins.  The short story
    -- is that it has always worked in the past with ISE, but Vivado generates 
    -- DRC error.  Can be bypassed by decoupling the clock from the perpective 
    -- of the tools by just toggling a flip flop, which is what is done below.
    process(clk_fr)
    begin
        if rising_edge(clk_fr) then
            decoupled_clk <= not decoupled_clk;
        end if;
    end process;

	phy: entity work.gig_ethernet_pcs_pma_0_block
		port map(
			drpaddr_in => (others => '0'),
			drpclk_in => clk125,
			drpdi_in => (others => '0'),
			drpdo_out => open,
			drpen_in => '0',
			drprdy_out => open,
			drpwe_in => '0',
			gtrefclk => clkin,
			txp => gt_txp,
			txn => gt_txn,
			rxp => gt_rxp,
			rxn => gt_rxn,
			txoutclk => txoutclk_ub,
			resetdone => phy_done,
			mmcm_locked => mmcm_locked,
			userclk => clk62_5,
			userclk2 => clk125,
			independent_clock_bufg => decoupled_clk, --clk_fr,
			pma_reset => rsti,
			gmii_txd => gmii_txd,
			gmii_tx_en => gmii_tx_en,
			gmii_tx_er => gmii_tx_er,
			gmii_rxd => gmii_rxd,
			gmii_rx_dv => gmii_rx_dv,
			gmii_rx_er => gmii_rx_er,
			gmii_isolate => open,
			configuration_vector => "00000",
			status_vector => status,
			reset => rsti,
			signal_detect => '1'
		);

end rtl;

