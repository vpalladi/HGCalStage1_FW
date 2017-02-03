import logging
import os
import time

from mp7.cli_core import defaultFmtStr, FunctorInterface
from collections import OrderedDict

import calol2

class FunkyInfo(FunctorInterface):
    @staticmethod
    def addArgs(subp):
        pass

    @staticmethod
    def run(board):
        logging.info('Endpoint summary')    
        for e in board.funkyMgr():
            print e.name(),e.width(),e.size()


class FunkyRead(FunctorInterface):

    @staticmethod
    def addArgs(subp):
        subp.add_argument('-o','--out','--outputpath', default='funkydata', help='Output path'+defaultFmtStr)
        subp.add_argument('-m','--mode', default='py', choices=['cpp','py'], help='Readback mode'+defaultFmtStr)

    @staticmethod
    def run(board, out, mode):
        funkyMap = OrderedDict()

        fmb = board.funkyMgr()

        outdir = os.path.dirname(out);
        if outdir:
            os.system('mkdir -p '+outdir)

        if mode == 'py':
            # print fmb
            fmb.unlock()
            # fmb.lock()
            for e in fmb:
                logging.info('Reading %s',e.name())
                funkyMap[e.name()] =  (e.width(),e.read())
                e.lock()

            logging.info('Writing endpoints to file %s',out)

            with open(out,'w') as f:

                for name,(width,data) in funkyMap.iteritems():
                    f.write('\'%s\'\n' % name)
                    for v in data:
                        f.write('0x%08x\n' % v)

        elif mode == 'cpp':
            logging.info('Reading FunkyMiniBus endpoints (cpp)')    

            fmb.readToFile(out)


class FunkyZeros(FunctorInterface):
    @staticmethod
    def addArgs(subp):
        pass

    @staticmethod
    def run(board):
        logging.info('Zeroing all Endpoints')    
        board.funkyMgr().autoConfigure(calol2.AllZeros())


class FunkyRecovery(FunctorInterface):
    @staticmethod
    def addArgs(subp):
        subp.add_argument('-p','--path', default='funkydata', help='Output path'+defaultFmtStr)


    @staticmethod
    def run(board, path):
        logging.info('Reloading enpoints from file %s',path)    
        board.funkyMgr().autoConfigure(calol2.MPLUTFileAccess(path))