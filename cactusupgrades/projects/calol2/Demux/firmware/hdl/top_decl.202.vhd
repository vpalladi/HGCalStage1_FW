-- top_decl
--
-- Defines constants for the whole device
--
-- Dave Newbold , June 2014

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE work.mp7_top_decl.ALL;

PACKAGE top_decl IS

  CONSTANT ALGO_REV : STD_LOGIC_VECTOR( 31 downto 0 ) := X"1001002a";
  CONSTANT BUILDSYS_BUILD_TIME : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := X"00000000" ; -- To be overwritten at build time
  CONSTANT BUILDSYS_BLAME_HASH : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := X"00000000" ; -- To be overwritten at build time

  CONSTANT LHC_BUNCH_COUNT     : INTEGER                         := 3564;
  CONSTANT LB_ADDR_WIDTH       : INTEGER                         := 10;
  CONSTANT DR_ADDR_WIDTH       : INTEGER                         := 9;
  CONSTANT RO_CHUNKS           : INTEGER                         := 32;
  CONSTANT CLOCK_RATIO         : INTEGER                         := 6;
  CONSTANT CLOCK_RATIO_PAYLOAD : INTEGER                         := 6;
  CONSTANT PAYLOAD_LATENCY     : INTEGER                         := 2;
  CONSTANT DAQ_N_BANKS         : INTEGER                         := 4 ; -- Number of readout banks
  CONSTANT DAQ_TRIGGER_MODES   : INTEGER                         := 2 ; -- Number of trigger modes for readout
  CONSTANT DAQ_N_CAP_CTRLS     : INTEGER                         := 4 ; -- Number of capture controls per trigger mode

  CONSTANT REGION_CONF         : region_conf_array_t             := (
    0  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 3 , 10 ) , -- 0 / 118
    1  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 3 , 10 ) , -- 1 / 117 *
    2  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 3 , 10 ) , -- 2 / 116
    3  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 4 , 11 ) , -- 3 / 115
    4  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 4 , 11 ) , -- 4 / 114 *
    5  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 4 , 11 ) , -- 5 / 113
    6  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 5 , 12 ) , -- 6 / 112
    7  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 5 , 12 ) , -- 7 / 111 *
    8  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 5 , 12 ) , -- 8 / 110
    9  => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 0 , 7 ) , -- 9 / 210
    10 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 0 , 7 ) , -- 10 / 211 *
    11 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 0 , 7 ) , -- 11 / 212
    12 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 1 , 8 ) , -- 12 / 213
    13 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 1 , 8 ) , -- 13 / 214 *
    14 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 1 , 8 ) , -- 14 / 215
    15 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 2 , 9 ) , -- 15 / 216
    16 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 2 , 9 ) , -- 16 / 217 *
    17 => ( gth_10g , u_crc32 , buf , demux , buf , u_crc32 , gth_10g , 2 , 9 ) -- 17 / 218
  );

END top_decl;
