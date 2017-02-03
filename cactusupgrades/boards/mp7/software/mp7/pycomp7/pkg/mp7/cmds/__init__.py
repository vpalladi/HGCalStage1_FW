# Pyton modules
import logging
import os
import sys

# MP7 Modules
import mp7
import mp7.tools.helpers as hlp
import mp7.tools.log_config

# MP7 Command Modules
from mp7.cli_core import defaultFmtStr, FunctorInterface, CommandAdaptor
from mp7.cli_plugins import Plugin, DevicePlugin, MmcPlugin, MP7MiniPlugin, MP7Plugin

import mmc 
import i2c
import datapath
import mgts
import infra
import readout

import uhal


###############################
#  >>>  Basic commmands  <<<  #
###############################
    
class DevicesLister(FunctorInterface):

    @staticmethod
    def run(connectionManager):
        logging.info('Available devices:')
        for d in connectionManager.getDevices():
            logging.info('   - %s', d)


#TODO : Move this command to helpers ??
class InspectNode(FunctorInterface):
    # TODO : Automatically convert buffer argument to being enum for CtrlNode::selectLinkBuffer WHEN command-line args are parsed (so that the inspectNode 'buffer' argument is that enum rather than string)
    @staticmethod
    def addArgs(subp):
        subp.add_argument('node', help='Node to inspect')
        subp.add_argument('--bynode', default=False, action='store_true', help='Node to inspect')
        subp.add_argument('--chan', type=int, default=None, help='Channel to inspect')
        subp.add_argument('--buffer', choices=['rx','tx'], default=None, help='Buffer to inspect')
        subp.add_argument('--romode', type=int, default=None, help='Readout mode to inspect')
        subp.add_argument('--rocapture', type=int, default=None, help='Readout capture to inspect')

    #TODO: Move this run function to helpers ??
    @staticmethod
    def run(board, node, bynode=False, chan=None, buffer=None, romode=None, rocapture=None):
        if chan is not None:
            if buffer is not None:
                b = {'rx': mp7.kRx, 'tx': mp7.kTx}[buffer]
                board.getDatapath().selectLinkBuffer(chan, b)
                logging.notice('Channel %d, buffer %s selected', chan, b)
            else:
                board.getDatapath().selectLink(chan)
                logging.notice('Channel %d selected', chan)

        if romode is not None:
            board.getReadout().getNode('readout_control').selectMode(romode)
            logging.notice('Readout mode %d selected', romode)

        if romode is not None:
            board.getReadout().getNode('readout_control').selectCapture(rocapture)
            logging.notice('Readout capture %d selected', rocapture)


        nodes = board.hw().getNodes(node)
        for subnode in nodes:
            n = board.hw().getNode(subnode)
            cl = n.getClient()

            if not bynode:
                v = n.read()
                snap = mp7.snapshot(n)

                print node, '=', hex(v)
                for k in sorted(snap):
                    print node+'.'+k, '=', hex(snap[k])
            else:
                print node, '=',
                sys.stdout.flush()
                v = n.read()
                cl.dispatch()
                print hex(v)

                for sn in sorted(n.getNodes()):
                    print node+'.'+sn, '=',
                    sys.stdout.flush()
                    v = n.getNode(sn).read()
                    cl.dispatch()
                    print hex(v)


#---
class WriteNode(FunctorInterface):
    # TODO : Automatically convert buffer argument to being enum for CtrlNode::selectLinkBuffer WHEN command-line args are parsed (so that the inspectNode 'buffer' argument is that enum rather than string)
    @staticmethod
    def addArgs(subp):
        subp.add_argument('node', help='Node to write')
        subp.add_argument('value', help='Value to write')
        subp.add_argument('-l','--chan', type=int, default=None, help='Channel to inspect')
        subp.add_argument('-b','--buffer', choices=['rx','tx'], default=None, help='Buffer to inspect')

    @staticmethod
    def run(board, node, value, chan=None, buffer=None):
        if chan is not None:
            if buffer is not None:
                b = {'rx': mp7.kRx, 'tx': mp7.kTx}[buffer]
                board.getDatapath().selectLinkBuffer(chan, b)
                logging.notice('Channel %d, buffer %s selected', chan, b)
            else:
                board.getDatapath().selectLink(chan)
                logging.notice('Channel %d selected', chan)
                
        logging.info("node %s, value %s", node, value)

        if value.startswith('0x'):
            value = int(value,16)
        else:
            value = int(value)

        n = board.hw().getNode(node)
        n.write(value)
        n.getClient().dispatch()

#---
class PythonCommand(FunctorInterface):
    # TODO : Automatically convert buffer argument to being enum for CtrlNode::selectLinkBuffer WHEN command-line args are parsed (so that the inspectNode 'buffer' argument is that enum rather than string)
    @staticmethod
    def addArgs(subp):
        subp.add_argument('command', help='Command to execute')

    @staticmethod
    def run(board, command):
        # if not command.startswith('board'):
            # throw ArgumentError('Alakazham!')

        logging.notice('Executing \'%s\'', command)
        exec(command)

#---
class Factory(object):
    """docstring for PluginFactory"""

    @classmethod
    def makeBasic( cls, pluginClass ):
        plugins = [
            Plugin('show', 'Show the list of known devices', DevicesLister()),
            DevicePlugin('connect', 'Test the connection to the selected board', CommandAdaptor(hlp.testAccess)),
            pluginClass('inspect', 'Print snapshot of board registers', InspectNode() ),
            pluginClass('write', 'Write a value in a registers', WriteNode() ),
            pluginClass('pycmd', 'executes a python command on the target', PythonCommand() ),
            pluginClass('ipy', 'Creates an MP7 controller object', CommandAdaptor( lambda board: board) )
           ]
        return plugins


    @classmethod
    def makeMMC( cls, pluginClass ):

        assert(issubclass(pluginClass,mp7.cli_plugins.Plugin))

        plugins  = [
            MmcPlugin('scansd', 'scan MicroSD card for files', CommandAdaptor(lambda board : hlp.listFilesOnSD(board)) ),
            MmcPlugin('uploadfw', 'upload firmware image to uSD', mmc.UploadFwImage()),
            MmcPlugin('downloadfw', 'Download firmware image from uSD card to path supplied on local disk', mmc.DownloadFwImage()),

            ##TODO: Add NonNullStringAction and/or FileExistsAction to remove repeated checking here ...
            #       Also, at same time, remove use of default="" in add_argument method call ??

            MmcPlugin('deletefw', 'Delete firmware image from uSD card', mmc.DeleteFwImage()),
            MmcPlugin('rebootfpga', 'Reboot fpga and load specific firmware image', mmc.RebootFpga()),
            MmcPlugin('hardreset', 'Hard reset the board', CommandAdaptor(lambda board: board.hardReset())),
            MmcPlugin('setdummysensor', 'set dummy sensor value for ipmi tests', mmc.SetDummySensor()),
        ]

        return plugins

    @classmethod
    def makeMP7Mini( cls, pluginClass = MP7MiniPlugin ):

        assert(issubclass(pluginClass,mp7.cli_plugins.Plugin))

        plugins = []

        plugins += cls.makeBasic( pluginClass )

        #####################################
        # TTC commands                      #
        #####################################

        plugins += [
            pluginClass('ttccheck', 'Check TTC block status', CommandAdaptor(lambda board: board.checkTTC()) ),
            pluginClass('ttcscan', 'Scans the TTC phase', CommandAdaptor(lambda board: board.scanTTCPhase()) ),
            pluginClass('ttccapture', 'Capture ttc commands', infra.TTCCapture()),
        ]

        #####################################
        #  >>>  Link-related commands  <<<  #
        #####################################

        plugins += [
            pluginClass('rxmgts', 'Configure rx mgts', mgts.RxMGTs() ),
            pluginClass('txmgts', 'Configure tx mgts', mgts.TxMGTs() ),
            pluginClass('rxalign', 'Align rx mgts', mgts.RxAlign() ),
            pluginClass('rxmgtscheck', 'Check rx mgts status', mgts.RxMGTsCheck()),
            pluginClass('rxaligncheck', 'Check rx mgts alignment status', mgts.RxAlignCheck()),
            pluginClass('eyescan', 'Produce amazing eyscans', mgts.EyeScan()),
        ]

        ##################################################
        #  >>>  Buffer/Formatter-related commands  <<<  #
        ##################################################

        plugins += [
            pluginClass('buffers', 'Configure buffers', datapath.Buffers()),
            pluginClass('xbuffers', 'Configure buffers', datapath.XBuffers()),
            pluginClass('latency', 'Configure buffers in latency mode', datapath.LatencyBuffers()),
            pluginClass('formatters', 'Configure formatters', datapath.Formatters()),
            pluginClass('capture', 'Perform data capture', datapath.Capture()),
            pluginClass('dump', 'Dump buffer content', datapath.Dump()),
        ]

        return plugins


    @classmethod
    def makeMP7( cls, pluginClass = MP7Plugin ):

        plugins = []

        #####################################
        #  Other commmands                  #
        #####################################
        plugins += [
            pluginClass('reset', 'Reset the board and set the clocking', infra.Reset() ),
            pluginClass('clocks', 'Measure the status of the clocks', infra.MeasureClocks() ),
            pluginClass('qdr', 'Test QDR RAM', CommandAdaptor(lambda board: hlp.qdrTest(board)) ),
        ]

        plugins += cls.makeMMC( pluginClass )

        #####################################
        #  I2C-related commmands            #
        #####################################
        plugins += [
            pluginClass('minipods', 'print minipod sensor info', i2c.PrintMinipodSensors() ),
            pluginClass('readsensors', 'Display MP7 sensor information', i2c.PrintSensors() ),
        ]

        plugins += cls.makeMP7Mini( pluginClass )

        ####################################
        #  >>>  Readout/DAQ commands  <<<  #
        ####################################
        plugins += [
            pluginClass('tmtreadout','TMT readout configuration', readout.TMTReadoutSetup()),
            pluginClass('ttscapture','Capture TTS History', readout.TTSCapture()),
            pluginClass('easylatency','Simple latency buffers setup', readout.EasyLatency()),
            pluginClass('rohistcapture','Capture Redout History', readout.HistoryCapture()),
            pluginClass('rosetup','Configure Readout module in simple mode', readout.Setup()),
            pluginClass('rorate','Run a rate test', readout.RateTest()),
            pluginClass('roratescan','Run a rate test', readout.RateScan()),
            pluginClass('roevents','Configure Readout module in simple mode', readout.CaptureEvents()),
            pluginClass('romenu','Load readout menu', readout.LoadMenu()),
            pluginClass('rodiagnostic','Readout register dump', readout.Diagnostic()),
        ]
        return plugins

#----------------
# COMMANDS += [
#     Plugin('show', 'Show the list of known devices', DevicesLister()),
#     DevicePlugin('connect', 'Test the connection to the selected board', CommandAdaptor(hlp.testAccess))
# ]

# #####################################
# #  >>>  Generic commmands  <<<      #
# #####################################

# genericCmds = [
#     ('inspect', 'Print snapshot of board registers', InspectNode() ),
#     ('write', 'Write a value in a registers', WriteNode() ),
#     # ('pycmd', 'executes a python command on the target', PythonCommand() ),
#     # ('ipy', 'Creates an MP7 controller object', CommandAdaptor( lambda board: board) )
# ]

# for args in genericCmds:
#     COMMANDS += [MP7Plugin(*args)]
#     MINICOMMANDS += [MP7MiniPlugin(*args)]


# # COMMANDS += [MP7Plugin('inspect', 'Print snapshot of board registers', InspectNode() )]

# # COMMANDS += [MP7Plugin('write', 'Write a value in a registers', WriteNode() )]

# COMMANDS += [
#     MP7Plugin('pycmd', 'executes a python command on the target', PythonCommand() ),
#     MP7Plugin('ipy', 'Creates an MP7 controller object', CommandAdaptor( lambda board: board) ),
# ]

# #####################################
# #  >>>  MMC-related commmands  <<<  #
# #####################################

# COMMANDS += [
#     MmcPlugin('scansd', 'scan MicroSD card for files', CommandAdaptor(lambda board : hlp.listFilesOnSD(board)) ),
#     MmcPlugin('uploadfw', 'upload firmware image to uSD', mmc.UploadFwImage()),
#     MmcPlugin('downloadfw', 'Download firmware image from uSD card to path supplied on local disk', mmc.DownloadFwImage()),

#     ##TODO: Add NonNullStringAction and/or FileExistsAction to remove repeated checking here ...
#     #       Also, at same time, remove use of default="" in add_argument method call ??

#     MmcPlugin('deletefw', 'Delete firmware image from uSD card', mmc.DeleteFwImage()),
#     MmcPlugin('rebootfpga', 'Reboot fpga and load specific firmware image', mmc.RebootFpga()),
#     MmcPlugin('hardreset', 'Hard reset the board', CommandAdaptor(lambda board: board.hardReset())),
#     MmcPlugin('setdummysensor', 'set dummy sensor value for ipmi tests', mmc.SetDummySensor()),
# ]

# #####################################
# #  >>>  I2C-related commmands  <<<  #
# #####################################
# COMMANDS += [
#     MP7Plugin('minipods', 'print minipod sensor info', i2c.PrintMinipodSensors() ),
#     MP7Plugin('readsensors', 'Display MP7 sensor information', i2c.PrintSensors() ),
# ]

# #####################################
# #  >>>  Other commmands  <<<        #
# #####################################
# COMMANDS += [
#     MP7Plugin('reset', 'Reset the board and set the clocking', infra.Reset() ),
#     MP7Plugin('clocks', 'Measure the status of the clocks', infra.MeasureClocks() ),
#     MP7Plugin('qdr', 'Test QDR RAM', CommandAdaptor(lambda board: hlp.qdrTest(board)) ),
# ]

# #####################################
# #  >>>  TTC commands  <<<           #
# #####################################

# ttcCmdsArgs = [
#     ('ttccheck', 'Check TTC block status', CommandAdaptor(lambda board: board.checkTTC()) ),
#     ('ttcscan', 'Scans the TTC phase', CommandAdaptor(lambda board: board.scanTTCPhase()) ),
#     ('ttccapture', 'Capture ttc commands', infra.TTCCapture()),
# ]

# for args in ttcCmdsArgs:
#     COMMANDS += [MP7Plugin(*args)]
#     MINICOMMANDS += [MP7MiniPlugin(*args)]

# #####################################
# #  >>>  Link-related commands  <<<  #
# #####################################

# mgtCmdArgs = [
#     ('rxmgts', 'Configure rx mgts', mgts.RxMGTs() ),
#     ('txmgts', 'Configure tx mgts', mgts.TxMGTs() ),
#     ('rxalign', 'Align rx mgts', mgts.RxAlign() ),
#     ('rxmgtscheck', 'Check rx mgts status', mgts.RxMGTsCheck()),
#     ('rxaligncheck', 'Check rx mgts alignment status', mgts.RxAlignCheck()),
#     ('eyescan', 'Produce amazing eyscans', mgts.EyeScan()),
# ]

# for args in mgtCmdArgs:
#     COMMANDS += [MP7Plugin(*args)]
#     MINICOMMANDS += [MP7MiniPlugin(*args)]

# ##################################################
# #  >>>  Buffer/Formatter-related commands  <<<  #
# ##################################################

# bufCmdArgs = [
#     ('buffers', 'Configure buffers', datapath.Buffers()),
#     ('xbuffers', 'Configure buffers', datapath.XBuffers()),
#     ('latency', 'Configure buffers in latency mode', datapath.LatencyBuffers()),
#     ('formatters', 'Configure formatters', datapath.Formatters()),
#     ('capture', 'Perform data capture', datapath.Capture()),
#     ('dump', 'Dump buffer content', datapath.Dump()),
# ]

# for args in bufCmdArgs:
#     COMMANDS += [MP7Plugin(*args)]
#     MINICOMMANDS += [MP7MiniPlugin(*args)]


# ####################################
# #  >>>  Readout/DAQ commands  <<<  #
# ####################################

# COMMANDS += [
#     MP7Plugin('tmtreadout','TMT readout configuration', readout.TMTReadoutSetup()),
#     MP7Plugin('ttscapture','Capture TTS History', readout.TTSCapture()),
#     MP7Plugin('easylatency','Simple latency buffers setup', readout.EasyLatency()),
#     MP7Plugin('rohistcapture','Capture Redout History', readout.HistoryCapture()),
#     MP7Plugin('rosetup','Configure Readout module in simple mode', readout.Setup()),
#     MP7Plugin('rorate','Run a rate test', readout.RateTest()),
#     MP7Plugin('roratescan','Run a rate test', readout.RateScan()),
#     MP7Plugin('roevents','Configure Readout module in simple mode', readout.CaptureEvents()),
#     MP7Plugin('romenu','Load readout menu', readout.LoadMenu()),
#     MP7Plugin('rodiagnostic','Readout register dump', readout.Diagnostic()),
# ]