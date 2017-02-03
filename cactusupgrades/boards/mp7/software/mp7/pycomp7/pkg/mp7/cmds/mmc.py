import logging
import os 

import uhal
import mp7

import mp7.tools.helpers as hlp

from mp7.cli_core import defaultFmtStr, FunctorInterface

#-----
class UploadFwImage(FunctorInterface):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('localfile', default='', help='Path to image file that will be uploaded to uSD')
        subp.add_argument('sdfile', default='', help='Name to give firmware image of uSD card')
        subp.add_argument('--no-scan', dest='scan', default=True, action='store_false', help='Scan uSD card after uploading')

    @staticmethod
    def run(board, localfile, sdfile, scan):
        if not localfile or not sdfile or not os.path.isfile(localfile):
            logging.error('No filepath or filename given, or file does not exist')
        else:
            logging.info('Uploading firmware image %s to uSD card ...' % sdfile)
            board.copyFileToSD(localfile, sdfile)
            if scan:
                hlp.listFilesOnSD(board)


class DownloadFwImage(FunctorInterface):
    @staticmethod
    def addArgs(subp):
       subp.add_argument('sdfile', default='', help='Firmware image filename to download from uSD card')
       subp.add_argument('localfile', default='', help='Path to download firmware image file from uSD to local disk')

    @staticmethod
    def run(board, localfile, sdfile):
        if not localfile or not sdfile:
            logging.error('No firmware image filename or path given')
        else:
            logging.info('Downloading image %s from uSD card to %s' % (sdfile, localfile))
            board.copyFileFromSD(localfile, sdfile)


class DeleteFwImage(FunctorInterface):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('sdfile', default="", help='Image filename to delete from uSD card')
        subp.add_argument('--no-scan', dest='scan', default=True, action='store_false', help='Scan uSD card after uploading')

    @staticmethod
    def run(board, sdfile, scan):
        if not sdfile:
            logging.error('No firmware image filename given')
        else:
            logging.info("Deleting image %s from uSD card..." % sdfile)
            board.deleteFileFromSD(sdfile)
            if scan:
                hlp.listFilesOnSD(board)

class RebootFpga(FunctorInterface):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('sdfile', default="", help='Preloaded firmware image to load after fpga reboot')

    @staticmethod
    def run(board, sdfile):
        if not sdfile:
           logging.error('No firmware image given. Listing image names on uSD...')
           hlp.listFilesOnSD(board)
        else:
            logging.info("Rebooting FPGA with firmware image %s..." % sdfile)
            uhal.setLogLevelTo(uhal.LogLevel.FATAL)
            board.rebootFPGA(sdfile)
            uhal.setLogLevelTo(uhal.LogLevel.ERROR)

class SetDummySensor(FunctorInterface):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('--value', dest='dummyval', default=-128, type=int, help='Value for dummy sensor')

    @staticmethod
    def run(board, dummyval):
        if not dummyval or (dummyval < -128 or dummyval > 127):
            logging.error('Invalid or no dummy sensor value given (range: -128,127). Defaulting to 0xff (-1)')
            dummyval=0xff
        else:
            logging.info("Setting dummy sensor to value: %d" % dummyval)
            board.setDummySensorValue(dummyval)
