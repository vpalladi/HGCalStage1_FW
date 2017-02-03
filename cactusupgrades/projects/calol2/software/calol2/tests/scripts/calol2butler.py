#!/bin/env python

'''
CaloL2 butler (version 1)
Title: mp7butler
Author: Alessandro Thea and Tom Williams

Example usage ...

mp7butler.py show
mp7butler.py reset MY_BOARD --clksrc=internal
mp7butler.py ...

'''


import logging
import mp7
from mp7.cli_core import defaultFmtStr

from mp7.cli_core import CLIEngine

from calol2.cmds import plugins 

if __name__ == '__main__':
    cli = CLIEngine()
    cli.setDefaultConnectionFiles(['file://${CALOL2_TESTS}/etc/calol2/connections-'+x+'.xml' for x in ['Schroff2', 'TDR']])

    for cmd in plugins:
        cli.addCommand(cmd)

    try:
        global result
        result = cli.run()
    except mp7.exception as e:
        logging.critical("%s",e)
    except RuntimeError as re:
        logging.critical("%s",re)
