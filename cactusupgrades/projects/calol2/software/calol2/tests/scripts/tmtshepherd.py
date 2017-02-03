#!/bin/env python

import logging
import errno
import os

import uhal

import mp7

from mp7.cli_core import CommandAdaptor, CLIEngine
from mp7.cli_plugins import Command, DeviceCommand
from mp7.orbit import Point, Metric
from mp7.tools.bufcfg import Configurator
from mp7.tools.cli_utils import IntListAction
import mp7.tools.helpers as hlp
import mp7.tools.data as data
import mp7.cmds

from daq.dtm import DTManager


def bxToCy( bxs ):
    return bxs*6


# mpAlignTo = 3556
# mpStart = mpAlignTo-2
# dmxAlignTo = mpAlignTo+26
# dmxStart = dmxAlignTo-2

# MP7 TMT metric
m = Metric(3564, 6)

# TMT period
tmtPeriod = 9

alignCaptureOffset = 2

# BX0 orbittag mismatch, in Bx
orbitTagBX0Offset = 3

# MP alignment point
# mpAlignTo = Point(3555) 
mpAlignTo = Point(3495) 

# Capture 2bxs before
mpStart = m.subBXs(mpAlignTo, alignCaptureOffset)

# Demux aligns 21bxs after MPs
dmxAlignTo = m.addBXs(mpAlignTo, 21)

# Demux captures 2 bx before the alignment point
dmxStart = m.subBXs(dmxAlignTo, alignCaptureOffset)

# Frames at which formatter should start and stop overwriting valid to '1' in demux output
#   * Start position determined by manual inspection of raw/demux/tx_summary.txt (Alessandro)
#   * Stop position corresponds to highest integer number of subsequent BXs (6 consecutive frames) that will fit within buffer (depth: 1024 frames) 
# dmxValStart = (dmxStart+4,3)
# dmxValStop = (dmxValStart[0]+160,dmxValStart[1])

# dmxValStart = (dmxStart+4,3+1)
# dmxValStop = (dmxValStart[0]+160,dmxValStart[1])




mpAllChans = range(72)
mpRxEnabledLinks = range(72)
mpRxDisabledLinks = range(0,0)
mpTxEnabledLinks = range(60,66)
mpTxDisabledLinks = range(0,60)+range(66,72)
mpSlots = [1,2,3,4,5,6,7,8,9]
FED = 1360

# mpMasterLatency = 395-orbitTagBX0Offset*6
# 3 Bxs removed in TS3
mpMasterLatency = 414-bxToCy(orbitTagBX0Offset)
mpAlgoLatency = 78

# dmxOutputs = range(0,72)
dmxTxEnabledLinks = [4,5,6,7,8,9,10]
dmxSlot = 3
dmxROExtraBx = 2
# 4 Bxs od invalid data
dmxDvWindowBXs = 3560
dmxDvOffsetBx = 3

# Some random numbers follow
# dmxMasterLatency = 269-orbitTagBX0Offset*6
# 3 Bxs removed in TS3
dmxMasterLatency = 251- bxToCy(orbitTagBX0Offset)
dmxAlgoBaseLatency = 16
dmxAlgoLatency = dmxAlgoBaseLatency-bxToCy(dmxROExtraBx) # -2Bx, required to center the 5Bx capture window of the demux menu

# dmxValStart = m.addCycles(dmxAlignTo, dmxAlgoBaseLatency+1)
# TOFIX: +1 if the header is not inserted...
# 
dmxValStart = m.addCycles(dmxAlignTo, bxToCy(orbitTagBX0Offset)+dmxAlgoBaseLatency+1)

# Move back the start point by the offset
dmxValStart = m.subBXs(dmxValStart, dmxDvOffsetBx)
dmxValStop = m.addBXs(dmxValStart, dmxDvWindowBXs)

CFG = {
    'mps_ids': range(0,tmtPeriod),
    'mps_all_chans':  mpAllChans,
    'mps_rx_links_enabled':  mpRxEnabledLinks,
    'mps_rx_links_disabled': mpRxDisabledLinks,
    'mps_tx_links_enabled':  mpTxEnabledLinks,
    'mps_tx_links_disabled': mpTxDisabledLinks,
    'mps_slots' : mpSlots,
    'mps_masterLatency': mpMasterLatency,
    'mps_algoLatency': mpAlgoLatency,
    'fedid': FED,

    'mp0_alignBx': mpAlignTo,
    'mp0_rx_firstBx': mpStart, 
    'mp0_tx_firstBx': mpStart, 


    'dmx_slot': dmxSlot,
    'dmx_tx_links_enabled': dmxTxEnabledLinks,
    'dmx_alignBx': dmxAlignTo,
    'dmx_rx_firstBx': dmxStart,
    'dmx_tx_firstBx': dmxStart,
    'dmx_valStart': dmxValStart,
    'dmx_valStop': dmxValStop,

    'dmx_masterLatency': dmxMasterLatency,
    'dmx_algoLatency': dmxAlgoLatency
}

#print CFG
import sys
#sys.exit(0)

CFG['dummyRx-mp'] = 'dummy/only-zeroes-mp-align{mp0_alignBx}-start{mp0_rx_firstBx}.txt'.format(**CFG)
CFG['dummyRx-demux'] = 'dummy/only-zeroes-demux-align{dmx_alignBx}-start{dmx_rx_firstBx}.txt'.format(**CFG)


#################################
#  >>>  General functions  <<<  #
#################################

def mergeFiles( merged, filenames ):
    with open(merged, 'w') as outfile:
        for fname in filenames:
            outfile.write('\n\n')
            with open(fname) as infile:
                outfile.write(infile.read())

def mkdir_p( path ):
    '''Equivalent to unix "mkdir -p". Makes directory, including parent dirs if not already present; no errors if dir already exists'''
    try:
        os.makedirs(path)
    except OSError as exc:
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise


############################################
#  >>>  Generic preparatory commands  <<<  #
############################################

class UploadFw(object):
    def __init__(self, boards):
        self._boards = boards

    @staticmethod
    def addArgs(subp):
        subp.add_argument('localfile', help='Local file name')
        subp.add_argument('sdfile', help='File name on SD card')

    def run(self, connectionManager, localfile, sdfile):
        for id in self._boards:
            board = mp7.MP7Controller(connectionManager.getDevice(id))
            mmcMgr = mp7.MP7Controller.mmcMgr(board)
            mmcMgr.copyFileToSD(localfile, sdfile)
            hlp.listFilesOnSD(board.mmcMgr())

## Two instances: one created with [mp-URIs] and the other with [demux-uri]

cmdMPsUpload = Command('mps-upload', 'Upload the selected firmware to ALL mps',
                       UploadFw(['MP'+str(mp) for mp in CFG['mps_ids']]))
cmdDmxUpload = Command('dmx-upload', 'Upload the selected firmware to demux',
                       UploadFw(['DEMUX']))


class DeleteFw(object):
    def __init__(self, boards):
        self._boards = boards

    @staticmethod
    def addArgs(subp):
        subp.add_argument('sdfile', help='File name on SD card')

    def run(self, connectionManager, sdfile):
        for id in self._boards:
            board = mp7.MP7Controller(connectionManager.getDevice(id))
            board.mmcMgr().deleteFileFromSD(sdfile)
            hlp.listFilesOnSD(board.mmcMgr())

## Two instances: one created with [mp-URIs] and the other with [demux-uri]

cmdMPsDelete = Command('mps-delete', 'Delete the selected firmware from ALL mps',
                       DeleteFw(['MP'+str(mp) for mp in CFG['mps_ids']]))
cmdDmxDelete = Command('dmx-delete', 'Delete the selected firmware from demux',
                       DeleteFw(['DEMUX']))


class Reboot(object):
    def __init__(self, boards):
        self._boards = boards

    @staticmethod
    def addArgs(subp):
        subp.add_argument('sdfile', help='File name on SD card')

    def run(self, connectionManager, sdfile):
        for id in self._boards:
            board = mp7.MP7Controller(connectionManager.getDevice(id))
             
            logging.info("Rebooting FPGA on MP7 '%s' with firmware image %s...", id, sdfile)
            uhal.setLogLevelTo(uhal.LogLevel.FATAL)
            board.mmcMgr().rebootFPGA(sdfile)
            uhal.setLogLevelTo(uhal.LogLevel.ERROR)

## Again, two instances - one with [mp-URIs] and the other with [demux-uri]

cmdMPsReboot = Command('mps-reboot', 'Reboot ALL the MPs to the chosen firmware image',
                       Reboot(['MP'+str(mp) for mp in CFG['mps_ids']]))

cmdDmxReboot = Command('dmx-reboot', 'Reboot Demux to the chosen firmware image',
                       Reboot(['DEMUX']))


def resetSystem(connectionManager):
    for id in ['MP'+str(mp) for mp in CFG['mps_ids']] + ['DEMUX']:
        board =  mp7.MP7Controller(connectionManager.getDevice(id))
        board.reset('external', 'external', 'external')
        if id is not 'DEMUX':
            setTMTCycleControlReg(board, int(id.replace("MP","")))
        else:
            setTMTCycleControlReg(board, id)

cmdReset = Command('reset', 'Reset MP and demux boards on external clock', CommandAdaptor(resetSystem))

def scanSDs(connectionManager):
    for id in ['MP'+str(mp) for mp in CFG['mps_ids']] + ['DEMUX']:
        board = mp7.MP7Controller(connectionManager.getDevice(id))
        hlp.listFilesOnSD(board.mmcMgr())

cmdScanSDs = Command('mps-scansd', 'Scan uSD for firmware for MPs & Demux', CommandAdaptor(scanSDs))

####################################
#  >>>  MP-specific commands  <<<  #
####################################

class MPsCommand(Command):
    '''
    Basic Command sub-class implementing the common interface for commands requiring an MP-ids argument.
    This argument is adapted to 'mps', a list of MP7Controller objects, for the run function
    '''
    def __init__(self,*args,**kwargs):
        super(MPsCommand,self).__init__(*args,**kwargs)

    @classmethod
    def _addArgs(cls, subp):
        super(MPsCommand,cls)._addArgs(subp)
        subp.add_argument('mpIDs', action=IntListAction, help='MP ids')

    @classmethod
    def prepare(cls, kwargs):
        super(MPsCommand,cls).prepare(kwargs)
        connMgr = kwargs.pop('connectionManager')
        kwargs['ids']    = sorted(kwargs.pop('mpIDs'))
        kwargs['boards'] = [mp7.MP7Controller(connMgr.getDevice('MP'+str(id))) 
                            for id in kwargs['ids']]


class MPsDAQCommand(Command):
    '''
    Command sub-class implementing the common interface for commands requiring an MP-ids argument.
    This argument is adapted to 'mps', a list of MP7Controller objects, for the run function, and 
    in addition, passes the amc13 devices
    '''
    def __init__(self,*args,**kwargs):
        super(MPsDAQCommand,self).__init__(*args,**kwargs)

    @classmethod
    def _addArgs(cls, subp):
        super(MPsDAQCommand,cls)._addArgs(subp)
        subp.add_argument('mpIDs', action=IntListAction, help='MP ids')

    @classmethod
    def prepare(cls, kwargs):
        super(MPsDAQCommand,cls).prepare(kwargs)
        connMgr = kwargs.pop('connectionManager')
        kwargs['ids']    = sorted(kwargs.pop('mpIDs'))
        kwargs['boards'] = [mp7.MP7Controller(connMgr.getDevice('MP'+str(id))) 
                            for id in kwargs['ids']]
        kwargs['amc13'] = DTManager(connMgr.getDevice('AMC13.T1'),
                            connMgr.getDevice('AMC13.T2'))

class DemuxCommand(Command):
    '''
    Basic Command sub-class implementing the common interface for commands requiring an MP-ids argument.
    This argument is adapted to 'mps' + 'demux', a list of MP7Controller objects, for the run function
    '''
    def __init__(self,*args,**kwargs):
        super(DemuxCommand,self).__init__(*args,**kwargs)

    @classmethod
    def _addArgs(cls, subp):
        super(DemuxCommand,cls)._addArgs(subp)
        subp.add_argument('mpIDs', action=IntListAction, help='MP ids')

    @classmethod
    def prepare(cls, kwargs):
        super(DemuxCommand,cls).prepare(kwargs)
        connMgr = kwargs.pop('connectionManager')
        kwargs['ids']    = sorted(kwargs.pop('mpIDs'))
        kwargs['demux']  = mp7.MP7Controller(connMgr.getDevice('DEMUX'))


class CaloL2DAQCommand(Command):
    '''
    Command sub-class implementing the common interface for commands requiring an MP-ids argument.
    This argument is adapted to 'mps', a list of MP7Controller objects, for the run function, and 
    in addition, passes the amc13 devices, and demux innit
    '''
    def __init__(self,*args,**kwargs):
        super(CaloL2DAQCommand,self).__init__(*args,**kwargs)

    @classmethod
    def _addArgs(cls, subp):
        super(CaloL2DAQCommand,cls)._addArgs(subp)
        subp.add_argument('mpIDs', action=IntListAction, help='MP ids')

    @classmethod
    def prepare(cls, kwargs):
        super(CaloL2DAQCommand,cls).prepare(kwargs)
        connMgr = kwargs.pop('connectionManager')
        kwargs['ids']    = sorted(kwargs.pop('mpIDs'))
        kwargs['boards'] = [mp7.MP7Controller(connMgr.getDevice('MP'+str(id))) 
                            for id in kwargs['ids']]
        kwargs['demux'] = mp7.MP7Controller(connMgr.getDevice('DEMUX'))
        kwargs['amc13'] = DTManager(connMgr.getDevice('AMC13.T1'),
                            connMgr.getDevice('AMC13.T2'))


class AMC13Command(Command):
    '''
    Basic Command sub-class implementing the common interface for commands requiring an amc13.
    '''
    def __init__(self,*args,**kwargs):
        super(AMC13Command,self).__init__(*args,**kwargs)

    @classmethod
    def prepare(cls, kwargs):
        super(AMC13Command,cls).prepare(kwargs)
        connMgr = kwargs.pop('connectionManager')
        kwargs['amc13'] = DTManager(connMgr.getDevice('AMC13.T1'),
                            connMgr.getDevice('AMC13.T2'))
     

def setTMTCycleControlReg(board, id):

    if id is not 'DEMUX':
        max_phase  = tmtPeriod-1
        l1a_offset = 0
        phase      = (id+2+orbitTagBX0Offset)%9
        pkt_offset = 0
    else:
        max_phase  = 0
        l1a_offset = 0
        phase      = 0
        pkt_offset = 0


    max_phase_node = board.hw().getNode('ttc.tmt.max_phase')
    old_max_phase = max_phase_node.read()
    max_phase_node.getClient().dispatch()

    l1a_offset_node = board.hw().getNode('ttc.tmt.l1a_offset')
    old_l1a_offset = l1a_offset_node.read()
    l1a_offset_node.getClient().dispatch()

    phase_node = board.hw().getNode('ttc.tmt.phase')
    old_phase = phase_node.read()
    phase_node.getClient().dispatch()

    pkt_offset_node = board.hw().getNode('ttc.tmt.pkt_offset')
    old_pkt_offset = pkt_offset_node.read()
    pkt_offset_node.getClient().dispatch()

    logging.info("Read old TMT values:    max_phase = %i, l1a_offset = %i, phase = %i, pkt_offset = %i", old_max_phase, old_l1a_offset, old_phase, old_pkt_offset)
    logging.info("Writing new TMT values: max_phase = %i, l1a_offset = %i, phase = %i, pkt_offset = %i", max_phase, l1a_offset, phase, pkt_offset)

    max_phase_node.write(max_phase)
    max_phase_node.getClient().dispatch()

    l1a_offset_node.write(l1a_offset)
    l1a_offset_node.getClient().dispatch()
    
    phase_node.write(phase)
    phase_node.getClient().dispatch()

    pkt_offset_node.write(pkt_offset)
    pkt_offset_node.getClient().dispatch()

    new_max_phase = max_phase_node.read()
    max_phase_node.getClient().dispatch()

    new_l1a_offset = l1a_offset_node.read()
    l1a_offset_node.getClient().dispatch()
    
    new_phase = phase_node.read()
    phase_node.getClient().dispatch()

    new_pkt_offset = pkt_offset_node.read()
    pkt_offset_node.getClient().dispatch()


    logging.info("Read new TMT values:    max_phase = %i, l1a_offset = %i, phase = %i, pkt_offset = %i", new_max_phase, new_l1a_offset, new_phase, new_pkt_offset)


def maskMPs(ids, boards):
    for board in boards:
        mp7.cmds.datapath.Buffers.run(board, 'zeroes')

cmdMPsMask = MPsCommand('mps-mask', "Mask the output of the selected MPs by configuring the buffers (rx+tx) in 'zero' mode", CommandAdaptor(maskMPs))


def configureMPsToSendMappingPattern(ids, boards):
    for id, board in zip(ids, boards):
        print id, board
        continue
        mp7.cmds.datapath.Buffers.run( board, 'loopPlay', data_uri='generate://orbitpattern', play_bx=(CFG['mp0_rx_firstBx']+id,None) )

cmdMPsPatts = MPsCommand('mps-patts', 'Configure MPs to send a pattern for mapping', CommandAdaptor(configureMPsToSendMappingPattern))


def prepareMPInputChannelFile(connectionManager):
    board = mp7.MP7Controller( connectionManager.getDevice('MP0') )
    # DEL board.enableChannels(CFG['mps_links_enabled'])
    mkdir_p('dummy')
    alPnt = CFG['mp0_alignBx']
    
    mp7.cmds.mgts.RxMGTs.run(board, enablechans=CFG['mps_rx_links_enabled'], orbittag=True)
    mp7.cmds.mgts.RxAlign.run(board, enablechans=CFG['mps_rx_links_enabled'], alignTo=alPnt)
    mp7.cmds.mgts.TxMGTs.run(board, enablechans=CFG['mps_tx_links_enabled'])
    # Calculate the start point for the rx channels
    rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],0)
    # Configure the buffers to capture from all links
    board = mp7.MP7Controller(connectionManager.getDevice('MP0'))    #connectionManager.getDevice('MP0')
    point = CFG['mp0_rx_firstBx']

    # Configure input channels
    # DEL board.enableChannels(CFG['mps_links_enabled'])
    mp7.cmds.datapath.XBuffers.run(board, 'rx', 'Capture', enablechans=CFG['mps_rx_links_enabled'], bx_range=(rxPoint,None))

    # Configure output channels
    # DEL board.enableChannels(CFG['mps_outputs'])
    mp7.cmds.datapath.XBuffers.run(board, 'tx', 'Capture', enablechans=CFG['mps_tx_links_enabled'], bx_range=(rxPoint,None))

    # Read the data from the buffers, and save to file 
    # Enable everything for capture
    # DEL board.enableChannels(CFG['mps_all_chans'])
    mp7.cmds.datapath.Capture.run(board, enablechans=CFG['mps_all_chans'], outputpath='raw/mp0')     #, depth=0)

    # Override the data valid pattern on in order to create template file
    input_data = mp7.BoardDataFactory.generate('file://raw/mp0/rx_summary.txt')
    template_data = data.overrideDataValidPattern(input_data, range(72), 0)
    mp7.BoardDataFactory.saveToFile(template_data, CFG['dummyRx-mp'])

cmdMPsPrepare = Command('mps-prepare', 'Prepare the template file to mask inout chammels later on. Uses MP0 inputs to build a template file mimicing the current packet structure from data, but zeroed payload', CommandAdaptor(prepareMPInputChannelFile))

def checkMPsAlignment(ids, boards):
    points = []
    for i, board in zip(ids, boards):
        
        # cm = hlp.channelMgr(board, [0])
        cm = board.channelMgr()

        cm.configureRxMGTs(True, True)

        ap = cm.minimizeAndAlignLinks(3)
        logging.notice("%s %s",id,ap)

        points.append( ap )

    # for i,p in points:
        # logging.info("MP")

    for k in range(len(points)-1):
        d = m.distance(points[k+1],points[k])

        # The alignment point must always increase from MP0 to MP8, in steps of 1BX +/- 1cycle
        # I.e. 6-1 < d < 6+1
        if d < 5 or d > 7:
            logging.error("Error: MP%d received data before or too close to MP%d (%s vs %s)", k, k+1, points[k],points[k+1])
        else:
            logging.notice("MP%d align %s > MP%d align %s", k, points[k], k+1, points[k+1])


        

cmdMPsCheckAlign = MPsCommand('mps-chkalign', 'Checks the MPs alignment sequence', CommandAdaptor(checkMPsAlignment))


def runMPs(ids, boards):
    for id, board in zip(ids, boards):
        # Configure input links
        # DEL board.enableChannels(CFG['mps_links_enabled'])
        alPoint = CFG['mp0_alignBx']
        mp7.cmds.mgts.RxMGTs.run(board, enablechans=CFG['mps_rx_links_enabled'], orbittag=True)
        mp7.cmds.mgts.RxAlign.run(board, enablechans=CFG['mps_rx_links_enabled'], alignTo=m.addBXs(alPoint,id))
        mp7.cmds.mgts.TxMGTs.run(board, enablechans=CFG['mps_tx_links_enabled'])

        # Calculate the start point for the rx channels
        rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],id)
        # Mask disabled channels by playing back the data-valid template
        # DEL board.enableChannels(CFG['mps_links_disabled'])

        if CFG['mps_rx_links_disabled']:
            # Replay dummy data on disabled channels
            mp7.cmds.datapath.XBuffers.run(board, 'rx', 'PlayOnce', enablechans=CFG['mps_rx_links_disabled'], data_uri='file://'+CFG['dummyRx-mp'], bx_range=(rxPoint,None))

        # Configure buffers to capture on enabled input channels
        # DEL board.enableChannels(CFG['mps_links_enabled'])
        mp7.cmds.datapath.XBuffers.run(board, 'rx', 'Capture', enablechans=CFG['mps_rx_links_enabled'], bx_range=(rxPoint,None))


        # Calculate the tx capture point for this board 
        txPoint = m.addBXs(CFG['mp0_tx_firstBx'],id)

        # Enable output channels only
        # DEL board.enableChannels(CFG['mps_outputs'])
        # Configure buffers to capture on output channels
        mp7.cmds.datapath.XBuffers.run( board, 'tx', 'Capture', enablechans=CFG['mps_tx_links_enabled'], bx_range=(txPoint,None))

        # DEL board.enableChannels(CFG['mps_all_chans'])
        # Configure formatters
        mp7.cmds.datapath.Formatters.run(board, enablechans=CFG['mps_all_chans'], tdr_fmt={'strip':True,'insert':True})

        # Read the data from the buffers, and save to file 
        mp7.cmds.datapath.Capture.run(board, enablechans=CFG['mps_all_chans'], outputpath='good/mp'+str(id))     #, depth=0)


    mkdir_p('merge')
    rx_filenames = [ 'good/mp%d/rx_summary.txt' % i for i in sorted(ids) ]
    tx_filenames = [ 'good/mp%d/tx_summary.txt' % i for i in sorted(ids) ]

    logging.info('Merging rx capture files')
    mergeFiles('merge/rx_summary.txt', rx_filenames)
    logging.info('Merging tx capture files')
    mergeFiles('merge/tx_summary.txt', tx_filenames)


cmdMPsRun = MPsCommand('mps-run', 'Configure and capture MPs i/o', CommandAdaptor(runMPs) )



def daqMPs(amc13, ids, boards):


    amc13.reset()

    for id, board in zip(ids, boards):
        # Reset Demux on external clock
        board.reset('external', 'external', 'external')
        setTMTCycleControlReg(board, id)
        # Configure input links
        # DEL board.enableChannels(CFG['mps_links_enabled'])
        alPoint = CFG['mp0_alignBx']
        amcSlots = [i+1 for i in ids]
        mp7.cmds.mgts.RxMGTs.run(board, enablechans=CFG['mps_rx_links_enabled'], orbittag=True)
        mp7.cmds.mgts.RxAlign.run(board, enablechans=CFG['mps_rx_links_enabled'], alignTo=m.addBXs(alPoint,id))
        mp7.cmds.mgts.TxMGTs.run(board, enablechans=CFG['mps_tx_links_enabled'])
        # Calculate the start point for the rx channels
        rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],id)
        # Mask disabled channels by playing back the data-valid template
        # DEL board.enableChannels(CFG['mps_links_disabled'])

        if CFG['mps_rx_links_disabled']:
            # Replay dummy data on disabled channels
            mp7.cmds.datapath.XBuffers.run(board, 'rx', 'PlayOnce', enablechans=CFG['mps_rx_links_disabled'], data_uri='file://'+CFG['dummyRx-mp'], bx_range=(rxPoint,None))

        # Configure buffers to capture on enabled input channels
        # DEL board.enableChannels(CFG['mps_links_enabled'])
        # mp7.cmds.datapath.XBuffers.run(board, 'rx', 'Capture', enablechans=CFG['mps_links_enabled'], bx_range=(rxPoint,None))


        # Calculate the tx capture point for this board 
        # txPoint = m.addBXs(CFG['mp0_tx_firstBx'],id)

        # Enable output channels only
        # DEL board.enableChannels(CFG['mps_outputs'])
        # Configure buffers to capture on output channels
        # mp7.cmds.datapath.XBuffers.run( board, 'tx', 'Capture', enablechans=CFG['mps_tx_links_enabled'], bx_range=(txPoint,None))

        # DEL board.enableChannels(CFG['mps_all_chans'])
        # Configure formatters
        mp7.cmds.datapath.Formatters.run(board, enablechans=CFG['mps_all_chans'], tdr_fmt={'strip':True,'insert':True})

        # Read the data from the buffers, and save to file 
        # mp7.cmds.datapath.Capture.run(board, enablechans=CFG['mps_all_chans'], outputpath='good/mp'+str(id))     #, depth=0)


        # Readout block setup
        mp7.cmds.readout.Setup.run(board, fake=False, fakesize=False, internal=False, drain=None, bxoffset=2)

        # Lateny buffers setup:
        # rx bank id = 1
        # tx bank id = 2
        # Only txs enabled atm
        mp7.cmds.readout.EasyLatency.run(board, rx=CFG['mps_all_chans'], tx=CFG['mps_tx_links_enabled'], rxBank=1, txBank=2, algoLatency=CFG['mps_algoLatency'], masterLatency=CFG['mps_masterLatency'])


        # Load a simple menu to start with
        mp7.cmds.readout.LoadMenu.run(board, '${MP7_TESTS}/python/daq/stage2.py','validationMps')


    # Configure 
    amc13.configure( amcSlots , CFG['fedid'], slink=True, bcnOffset = (0xdec-23))
    amc13.start()



cmdMPsDAQ = MPsDAQCommand('mps-daq', 'Configure and capture MPs in DAQ mode', CommandAdaptor(daqMPs) )

#
# MPs Replay
#

class MPsReplay(object):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('path', help='Base path of the captures working area')

    @staticmethod
    def run(ids, boards, path):
        for id, board in zip(ids, boards):        
           
            mp7.cmds.mgts.TxMGTs.run(board)

            mp7.cmds.datapath.Formatters.run(board, tdr_fmt={'strip':True,'insert':True})
        
            
            # Calculate the rx capture bx
            rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],id)
            # Configure all input channels fo data playback
            
            # DEL board.enableChannels(CFG['mps_all_chans'])
            # Configure rx buffer in playback
            mp7.cmds.datapath.XBuffers.run(board, 'rx', 'PlayOnce', enablechans=CFG['mps_all_chans'], data_uri='file://{path}/good/mp{mpId}/rx_summary.txt'.format(mpId=id, path=path), bx_range=(rxPoint,None))

            # Calculate the tx capture bx
            txPoint = m.addBXs(CFG['mp0_tx_firstBx'],id)
            # Only output buffers
            # DEL board.enableChannels(CFG['mps_outputs'])
            # Configure tx buffers to capture
            mp7.cmds.datapath.XBuffers.run( board, 'tx', 'Capture',enablechans=CFG['mps_tx_links_enabled'], bx_range=(txPoint,None))

            # Capture buffer contents
            mp7.cmds.datapath.Capture.run(board, enablechans=CFG['mps_all_chans'], outputpath='good/mp{mpId}'.format(mpId=id))
    
        mkdir_p('merge')
        rx_filenames = [ 'good/mp%d/rx_summary.txt' % i for i in sorted(ids) ]
        tx_filenames = [ 'good/mp%d/tx_summary.txt' % i for i in sorted(ids) ]

        logging.info('Merging rx capture files')
        mergeFiles('merge/rx_summary.txt', rx_filenames)
        logging.info('Merging tx capture files')
        mergeFiles('merge/tx_summary.txt', tx_filenames)



cmdMPsReplay = MPsCommand('mps-replay', 'Replay and MPs outputs from previous captures', MPsReplay() )


class MPsDAQReplay(object):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('path', help='Base path of the captures working area')

    @staticmethod
    def run(ids, boards, amc13, path):

        amcSlots = [i+1 for i in ids]

                                    
        amc13.reset()

        for id, board in zip(ids, boards):
            board.reset('external', 'external', 'external')
            setTMTCycleControlReg(board, id)

            #mp7.cmds.mgts.RxMGTs.run(board, orbittag=True)
            mp7.cmds.mgts.TxMGTs.run(board)

            mp7.cmds.datapath.Formatters.run(board, tdr_fmt={'strip':True,'insert':True})
        
            # Calculate the rx capture bx
            rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],id)
            # Configure all input channels fo data playback
            
            # DEL board.enableChannels(CFG['mps_all_chans'])
            # Configure rx buffer in playback
            mp7.cmds.datapath.XBuffers.run(board, 'rx', 'PlayOnce', enablechans=CFG['mps_all_chans'], data_uri='file://{path}/good/mp{mpId}/rx_summary.txt'.format(mpId=id, path=path), bx_range=(rxPoint,None))
 
            # Readout block setup
            mp7.cmds.readout.Setup.run(board, fake=False, fakesize=False, internal=False, drain=None, bxoffset=2)

            # Lateny buffers setup:
            # rx bank id = 1
            # tx bank id = 2
            # Only txs enabled atm
            mp7.cmds.readout.EasyLatency.run(board, rx=None, tx=CFG['mps_tx_links_enabled'], rxBank=1, txBank=2, algoLatency=CFG['mps_algoLatency'], masterLatency=CFG['mps_masterLatency'])


            # Load a simple menu to start with
            mp7.cmds.readout.LoadMenu.run(board, '${MP7_TESTS}/python/daq/stage2.py','simpleMPs')


        # Configure 
        amc13.configure( amcSlots , CFG['fedid'], slink=True, bcnOffset = (0xdec-23))
        amc13.start()

cmdMPsDAQReplay = MPsDAQCommand('mps-daq-replay', 'Replay and MPs outputs from previous captures, outpus in capture mode', MPsDAQReplay() )


class CaloL2DAQReplay(object):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('path', help='Base path of the captures working area')

    @staticmethod
    def run(ids, boards, demux, amc13, path):
        
        amc13.reset()

        for id, board in zip(ids, boards):
            board.reset('external', 'external', 'external')
            
            setTMTCycleControlReg(board, id)
            
            mp7.cmds.mgts.RxMGTs.run(board, orbittag=True)
            mp7.cmds.mgts.TxMGTs.run(board)

            mp7.cmds.datapath.Formatters.run(board, tdr_fmt={'strip':True,'insert':True})
        
            # Calculate the rx capture bx
            rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],id)
            
            # Configure rx buffer in playback
            mp7.cmds.datapath.XBuffers.run(board, 'rx', 'PlayOnce', enablechans=CFG['mps_all_chans'], data_uri='file://{path}/good/mp{mpId}/rx_summary.txt'.format(mpId=id, path=path), bx_range=(rxPoint,None))

            # Readout block setup
            mp7.cmds.readout.Setup.run(board, fake=False, fakesize=False, internal=False, drain=None, bxoffset=2)

            # Lateny buffers setup:
            # rx bank id = 1
            # tx bank id = 2
            # Only txs enabled atm
            mp7.cmds.readout.EasyLatency.run(board, rx=None, tx=CFG['mps_tx_links_enabled'], rxBank=1, txBank=2, algoLatency=CFG['mps_algoLatency'], masterLatency=CFG['mps_masterLatency'])


            # Load a simple menu to start with
            mp7.cmds.readout.LoadMenu.run(board, '${MP7_TESTS}/python/daq/stage2.py','simpleMPs')


        allchans = range(0,72)
        rxEnabledChans = range(0,0)
        #for mp in ids:
        #    rxEnabledChans.extend( [l+mp for l in xrange(0,72,12) ] )
    
        rxEnabledChans = [0,1,2,3,4,6,7,8,9,10,12,13,14,15,16,18,19,20,21,22,24,25,26,27,28,30,31,32,33,34,
                          66,67,68,69,60,61,62,63,54,55,56,57,48,49,50,51,42,43,44,45,36,37,38,39]
        
        rxEnabledChans = sorted(rxEnabledChans)
        rxDisabledChans = [l for l in allchans if not l in rxEnabledChans]
        
        # Reset Demux on external clock
        demux.reset('external', 'external', 'external')
        setTMTCycleControlReg(demux, 'DEMUX')
        setDemuxIDs(demux)
            
        # demux.enableChannels(enabledChans)
        mp7.cmds.mgts.RxMGTs.run(demux, enablechans=rxEnabledChans, orbittag=True)
        mp7.cmds.mgts.RxAlign.run(demux, enablechans=rxEnabledChans, dmx_delays=True, alignTo=(CFG['dmx_alignBx'].bx,0))
        mp7.cmds.mgts.TxMGTs.run(demux, enablechans=CFG['dmx_tx_links_enabled'])
        
        mp7.cmds.datapath.XBuffers.run(demux, 'rx', 'Zeroes', enablechans=rxDisabledChans, bx_range=(CFG['dmx_rx_firstBx'],None) )


        valfmt = {
            'start': (
                CFG['dmx_valStart'].bx,
                CFG['dmx_valStart'].cycle,
                ),
            'stop': (
                CFG['dmx_valStop'].bx,
                CFG['dmx_valStop'].cycle,
                )
            } 
        mp7.cmds.datapath.Formatters.run(demux, enablechans=allchans, dmx_hdrfmt={'strip':True,'insert':True}, dmx_valfmt=valfmt)
        # Readout block setup
        mp7.cmds.readout.Setup.run(demux, fake=False, fakesize=False, internal=False, drain=None, bxoffset=2)
            
        mp7.cmds.readout.EasyLatency.run(demux, rx=rxEnabledChans,tx=CFG['dmx_tx_links_enabled'],rxBank=1,txBank=2,algoLatency=CFG['dmx_algoLatency'], masterLatency=CFG['dmx_masterLatency'])
    
        # Load a simple menu to start with
        mp7.cmds.readout.LoadMenu.run(demux, '${MP7_TESTS}/python/daq/stage2.py','validationDemux5BX')
        
        # Configure 
        amc13.configure( [ CFG['dmx_slot'] ] , CFG['fedid'], slink=True, bcnOffset = (0xdec-23))
        amc13.start()
        
cmdCaloL2DAQReplay = CaloL2DAQCommand('calol2-daq-replay', 'Replay MPs outputs from previous captures, outpus in capture mode, sets up Demux daq also', CaloL2DAQReplay() )



class MPsCapture(object):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('path', help='Output path')
        subp.add_argument('--offset', dest='offset', default=0, type=int, help='Capture offset ')

    @staticmethod
    def run(ids, boards, path, offset):

        print path,offset
        for id, board in zip(ids, boards):        
            
            # Calculate the rx capture bx
            rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],offset+id)
            # Configure all input channels fo data playback
            
            # DEL board.enableChannels(CFG['mps_all_chans'])
            # Configure rx buffer in playback
            mp7.cmds.datapath.XBuffers.run(board, 'rx', 'Capture', enablechans=CFG['mps_all_chans'], bx_range=(rxPoint,None))
 
            # Calculate the tx capture bx
            txPoint = m.addBXs(CFG['mp0_tx_firstBx'],offset+id)
            # Only output buffers
            # DEL board.enableChannels(CFG['mps_outputs'])
            # Configure tx buffers to capture
            mp7.cmds.datapath.XBuffers.run( board, 'tx', 'Capture',enablechans=CFG['mps_tx_links_enabled'], bx_range=(txPoint,None))

            # Capture buffer contents
            mp7.cmds.datapath.Capture.run(board, enablechans=CFG['mps_all_chans'], outputpath='capture_off{capOffset}/mp{mpId}'.format(mpId=id, capOffset=offset))



cmdMPsCapture = MPsCommand('mps-capture', 'Replay and MPs outputs from previous captures', MPsCapture() )



#######################################
#  >>>  Demux-specific commands  <<<  #
#######################################


#new function to set board ID of demux to 0x221b
def setDemuxIDs(demux):

    # firmware regs are 3 ids times 8 width, not 4 ids times 4 width
    # so for now we set the wrong values to get 0x221b in readout to match offline

    bid  = 11
    cid  = 1
    comp = 2
    sys  = 2

    bid_node = demux.hw().getNode('ctrl.board_id.board')
    old_bid = bid_node.read()
    bid_node.getClient().dispatch()

    cid_node = demux.hw().getNode('ctrl.board_id.crate')
    old_cid = cid_node.read()
    cid_node.getClient().dispatch()

    comp_node = demux.hw().getNode('ctrl.board_id.component')
    old_comp = comp_node.read()
    comp_node.getClient().dispatch()

    sys_node = demux.hw().getNode('ctrl.board_id.system')
    old_sys = sys_node.read()
    sys_node.getClient().dispatch()
    
    logging.info("Read old ids:    sys id = %i, component id = %i, crate id = %i, board id = %i", old_sys, old_comp, old_cid, old_bid)

    logging.info("Writing new ids: sys id = %i, component id = %i, crate id = %i, board id = %i", sys, comp, cid, bid)

    bid_node.write(bid)
    bid_node.getClient().dispatch()

    cid_node.write(cid)
    cid_node.getClient().dispatch()

    comp_node.write(comp)
    comp_node.getClient().dispatch()

    sys_node.write(sys)
    sys_node.getClient().dispatch()

    new_bid = bid_node.read()
    bid_node.getClient().dispatch()

    new_cid = cid_node.read()
    cid_node.getClient().dispatch()

    new_comp = comp_node.read()
    comp_node.getClient().dispatch()

    new_sys = sys_node.read()
    sys_node.getClient().dispatch()

    logging.info("Read new ids:    sys id = %i, component id = %i, crate id = %i, board id = %i", new_sys, new_comp, new_cid, new_bid)


def runDemux(ids, demux):
    
    setDemuxIDs(demux)
    
    # TODO: Check with Greg if this command is still requiered.
    # If the non-connected tx channels are forced to 0, the formatter already provides the DV in the right place
    allchans = range(0,72)
    rxEnabledChans = range(0,0)
    #for mp in ids:
    #    rxEnabledChans.extend( [ l+mp for l in xrange(0,72,12) ] )

    rxEnabledChans = [0,1,2,3,4,6,7,8,9,10,12,13,14,15,16,18,19,20,21,22,24,25,26,27,28,30,31,32,33,34,
                      66,67,68,69,60,61,62,63,54,55,56,57,48,49,50,51,42,43,44,45,36,37,38,39]

    # sort the channels, otherwise the masking logic gets confused
    rxEnabledChans = sorted(rxEnabledChans)
    rxDisabledChans = [ l for l in allchans if not l in rxEnabledChans]

    # DEL demux.enableChannels(enabledChans)
    mp7.cmds.mgts.RxMGTs.run(demux, enablechans=rxEnabledChans, orbittag=True)
    mp7.cmds.mgts.TxMGTs.run(demux, enablechans=CFG['dmx_tx_links_enabled'])
    mp7.cmds.mgts.RxAlign.run(demux, enablechans=rxEnabledChans, dmx_delays=True, alignTo=(CFG['dmx_alignBx'].bx,0))

    # Mask disabled channels playing back an empty buffer (can Zeroes be used?)
    # demux.enableChannels(disabledChans)
    mp7.cmds.datapath.XBuffers.run(demux, 'rx', 'PlayOnce', enablechans=rxDisabledChans, data_uri='generate://empty', bx_range=(CFG['dmx_rx_firstBx'],None) )

    # Capture on enabled input channels
    # demux.enableChannels(enabledChans)
    mp7.cmds.datapath.XBuffers.run(demux, 'rx', 'Capture', enablechans=rxEnabledChans, bx_range=(CFG['dmx_rx_firstBx'],None) )

    # Capture all outputs - 6,7,10 should be full, the rest zeroes
    # demux.enableChannels(CFG['dmx_outputs'])
    mp7.cmds.datapath.XBuffers.run(demux, 'tx', 'Capture', enablechans=CFG['dmx_tx_links_enabled'], bx_range=(CFG['dmx_tx_firstBx'],None))

    # Configure formatters
    # demux.enableChannels(allchans)
    valfmt = {
                'start': (
                            CFG['dmx_valStart'].bx,
                            CFG['dmx_valStart'].cycle,
                        ),
                 'stop': (
                            CFG['dmx_valStop'].bx,
                            CFG['dmx_valStop'].cycle,
                        )
             } 
    # mp7.cmds.datapath.Formatters.run(demux, enablechans=allchans, dmx_hdrfmt={'strip':True,'insert':True}, dmx_valfmt=valfmt)
    # GT needs no header
    mp7.cmds.datapath.Formatters.run(demux, enablechans=allchans, dmx_hdrfmt={'strip':True,'insert':False}, dmx_valfmt=valfmt)
    # mp7.cmds.datapath.Formatters.run(demux, dmx_hdrfmt={'strip':True,'insert':False}, dmx_valfmt='disable')
    
    # Create a datavalid template
    mp7.cmds.datapath.Capture.run(demux, enablechans=allchans, outputpath='good/demux' )    



cmdDmxRun = DemuxCommand('dmx-run', 'Configure and capture demux i/o', CommandAdaptor(runDemux))


def checkL2demuxPatchPanelMap(demux):
    
    links = demux.getChannelIDs()
    ctrl = demux.getCtrl()
    align = demux.getAlignmentMonitor()
    ttc = demux.getTTC()

    logging.notice("Configuring links")

    try:
        # Configure GTHs in loopback mode
        demux.channelMgr().configureLinks(False, True)
    except StandardError as e:
        logging.exception('Aaaaarg!')
        logging.critical(e)

    logging.notice("Detecting alignment markers")
    markers = []
    for l in links.channels():
        ctrl.selectLink(l)
        align.reset()
        align.clear()
        if align.markerDetected():
            markers.append(l)

    logging.notice("Found channels %s",markers)
    logging.notice("Aligning links %s",markers)
    demux.channelMgr(markers).minimizeAndAlignLinks(3);

    # Instantiate a buffer
    bufferConfigurator = Configurator.withBXRange( demux, 'captureRxTx', playbx=(0x0,None), capbx=(0x0,None) )

    # Apply the selected configuration
    bufferConfigurator.configure(demux)

    # Capture the buffers
    ttc.forceBTest()

    # Retrieve data
    rxData = demux.channelMgr().readBuffers(mp7.BufferKind.kRxBuffer)

    hdr = None
    for i,frame in enumerate(rxData[markers[0]]):
        if not frame.valid:
            continue

        logging.info("Header found at %s %s",i,frame)
        hdr = i
        break

    logging.notice("Link mapping summary")
    for c in markers:
        frame = rxData[c][hdr+1]
        lid = (frame.data >> 24)
        logging.info("Demux %02d - MP %02d",c,lid)

cmdDmxMap = DemuxCommand('dmx-map', 'Display the dmx-mps channel map', CommandAdaptor(checkL2demuxPatchPanelMap))

## ---
def calol2Daq(ids, boards, demux, amc13):

    for id, board in zip(ids, boards):
        
        amc13.reset()
        board.reset('external', 'external', 'external')
        setTMTCycleControlReg(board, id)
        alPoint = CFG['mp0_alignBx']
        amcSlots = [i+1 for i in ids]
        
        mp7.cmds.mgts.RxMGTs.run(board, enablechans=CFG['mps_rx_links_enabled'], orbittag=True)
        mp7.cmds.mgts.RxAlign.run(board, enablechans=CFG['mps_rx_links_enabled'], alignTo=m.addBXs(alPoint,id))
        mp7.cmds.mgts.TxMGTs.run(board, enablechans=CFG['mps_tx_links_enabled'])

        # Calculate the start point for the rx channels
        rxPoint = m.addBXs(CFG['mp0_rx_firstBx'],id)
        
        if CFG['mps_rx_links_disabled']:
            # Replay dummy data on disabled channels
            mp7.cmds.datapath.XBuffers.run(board, 'rx', 'PlayOnce', enablechans=CFG['mps_rx_links_disabled'], data_uri='file://'+CFG['dummyRx-mp'], bx_range=(rxPoint,None))
            
        mp7.cmds.datapath.Formatters.run(board, enablechans=CFG['mps_all_chans'], tdr_fmt={'strip':True,'insert':True})

        mp7.cmds.readout.Setup.run(board, fake=False, fakesize=False, internal=False, drain=None, bxoffset=2)
        
        mp7.cmds.readout.EasyLatency.run(board, rx=CFG['mps_all_chans'], tx=CFG['mps_tx_links_enabled'], rxBank=1, txBank=2, algoLatency=CFG['mps_algoLatency'], masterLatency=CFG['mps_masterLatency'])

        mp7.cmds.readout.LoadMenu.run(board, '${MP7_TESTS}/python/daq/stage2.py','validationMps')

    allchans = range(0,72)
    rxEnabledChans = range(0,0)
    #for mp in ids:
    #    rxEnabledChans.extend( [l+mp for l in xrange(0,72,12) ] )
        
    rxEnabledChans = [0,1,2,3,4,6,7,8,9,10,12,13,14,15,16,18,19,20,21,22,24,25,26,27,28,30,31,32,33,34,
                      66,67,68,69,60,61,62,63,54,55,56,57,48,49,50,51,42,43,44,45,36,37,38,39]
            
    rxEnabledChans = sorted(rxEnabledChans)
    rxDisabledChans = [l for l in allchans if not l in rxEnabledChans]

    # Reset Demux on external clock
    demux.reset('external', 'external', 'external')
    setTMTCycleControlReg(demux, ['DEMUX'])
    setDemuxIDs(demux)
            
    mp7.cmds.mgts.RxMGTs.run(demux, enablechans=rxEnabledChans, orbittag=True)
    mp7.cmds.mgts.RxAlign.run(demux, enablechans=rxEnabledChans, dmx_delays=True, alignTo=(CFG['dmx_alignBx'].bx,0))
    mp7.cmds.mgts.TxMGTs.run(demux, enablechans=CFG['dmx_tx_links_enabled'])
        
    mp7.cmds.datapath.XBuffers.run(demux, 'rx', 'Zeroes', enablechans=rxDisabledChans, bx_range=(CFG['dmx_rx_firstBx'],None) )
        
    valfmt = {
        'start': (
            CFG['dmx_valStart'].bx,
            CFG['dmx_valStart'].cycle,
            ),
        'stop': (
            CFG['dmx_valStop'].bx,
            CFG['dmx_valStop'].cycle,
            )
        } 
    
    mp7.cmds.datapath.Formatters.run(demux, enablechans=allchans, dmx_hdrfmt={'strip':True,'insert':True}, dmx_valfmt=valfmt)
    # Readout block setup
    mp7.cmds.readout.Setup.run(demux, fake=False, fakesize=False, internal=False, drain=None, bxoffset=2)
            
    mp7.cmds.readout.EasyLatency.run(demux, rx=rxEnabledChans,tx=CFG['dmx_tx_links_enabled'],rxBank=1,txBank=2,algoLatency=CFG['dmx_algoLatency'], masterLatency=CFG['dmx_masterLatency'])
            
    # Load a simple menu to start with
    mp7.cmds.readout.LoadMenu.run(demux, '${MP7_TESTS}/python/daq/stage2.py','validationDemux5BX')
        
    # Configure 
    amc13.configure( [ CFG['dmx_slot'] ] , CFG['fedid'], slink=True, bcnOffset = (0xdec-23))
    amc13.start()

cmdCaloL2Daq = CaloL2DAQCommand('calol2-daq', 'Configure mps and demux & amc13 for DAQ operations', CommandAdaptor(calol2Daq))
        

# ---
def daqSpy(amc13):
    
    amc13.spy()

cmdDaqSpy = AMC13Command('daq-spy', 'Spy on AMC13 event buffer', CommandAdaptor(daqSpy))


# ---
def amc13Reset(amc13):
    
    amc13.reset()
    logging.info('Demux AMC13 reset done')

 
cmdAMC13Reset = AMC13Command('amc13-reset', 'Reset Demux and MPs AMC13', CommandAdaptor(amc13Reset))

# ---
def dummyDAQ(amc13):
    # TODO: Check with Greg if this command is still requiered.
    # If the non-connected tx channels are forced to 0, the formatter already provides the DV in the right place
    # allchans = range(0,72)
    # enabledChans = range(0,0)
    # for mp in ids:
    #     enabledChans.extend( [ l+mp for l in xrange(0,72,12) ] )

    # # sort the channels, otherwise the masking logic gets confused
    # enabledChans = sorted(enabledChans)
    # disabledChans = [ l for l in allchans if not l in enabledChans]

    # board = mp7.MP7Controller( connectionManager.getDevice('DEMUX') )

    amc13.reset()

    amc13.configure( [] , CFG['fedid'], True, False, True, 0xdec-23)
    amc13.start()

    
cmdDummyDAQ = AMC13Command('daq-dummy', 'Dummy DAQ configuration', CommandAdaptor(dummyDAQ))


##################################
#  >>>  Run the  engine  <<<  #
##################################


if __name__ == '__main__':

    cli = CLIEngine('Script to configure the TDR Calo Trigger Layer 2 and Demux in TMT mode')

    cli.setDefaultConnectionFiles(['file://${CALOL2_TESTS}/etc/mp7/connections-'+x+'.xml' for x in ['TDR']])

    commands = [cmdMPsUpload, cmdDmxUpload, cmdMPsDelete, cmdDmxDelete, cmdScanSDs, cmdMPsReboot, cmdDmxReboot, cmdReset]
    commands += [cmdMPsMask, cmdMPsPatts, cmdMPsPrepare, cmdMPsRun, cmdMPsReplay, cmdMPsDAQ, cmdMPsDAQReplay, cmdMPsCheckAlign, cmdMPsCapture]
    commands += [cmdDmxRun, cmdDummyDAQ, cmdAMC13Reset, cmdDmxMap]
    commands += [cmdCaloL2Daq, cmdDaqSpy, cmdCaloL2DAQReplay]

    for cmd in commands:
        cli.addCommand( cmd )

    cli.run()



