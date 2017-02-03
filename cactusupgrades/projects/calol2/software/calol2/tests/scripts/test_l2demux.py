#!/bin/env python

from mp7.tools.cli_utils import IntListAction

connections = 'file://${MP7_TESTS}/etc/mp7/schroff_L2P5.xml;file://${MP7_TESTS}/etc/mp7/vadatech_demuxP5.xml'

tmtBoards = {
     0 : 'XE_A5',
     1 : 'XE_95',
     2 : 'XE_A3',
     3 : 'XE_A6',
     4 : 'XE_9C',
     5 : 'XE_A2',
     6 : 'XE_9D',
     7 : 'XE_9F',
     8 : 'XE_97',
     9 : 'XE_A4',
    10 : 'XE_9A',
  #  10 : 'XE_98',
}

import subprocess
import argparse

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
subparsers = parser.add_subparsers(dest = 'cmd')
subp = subparsers.add_parser('reset')
subp = subparsers.add_parser('mask')
subp = subparsers.add_parser('enable')
subp.add_argument('ids', action=IntListAction, help='TMT board ids')
subp = subparsers.add_parser('map')

args = parser.parse_args()

# Reset
if args.cmd == 'reset':
    cmdTmpl = 'mp7butler.py -c %s reset %s'
    for i in sorted(tmtBoards):
        board = tmtBoards[i]
        print i,board
        
        cmd = cmdTmpl % (connections,board)
        print cmd
        subprocess.call(cmd.split())

# Mask
elif args.cmd == 'mask':
    cmdTmpl = 'mp7butler.py -c %s buffers %s zeroes'
    
    for i in sorted(tmtBoards):
        board = tmtBoards[i]
        print i,board
        
        cmd = cmdTmpl % (connections,board)
        print cmd
        subprocess.call(cmd.split())

elif args.cmd == 'enable':
    cmdTmpl = 'mp7butler.py -c %s buffers %s loopPlay --inject generate://orbitpattern --play %s'

    for i in args.ids:
        board = tmtBoards[i]
        cmd = cmdTmpl % (connections,board,i)
    
        print cmd
        subprocess.call(cmd.split())

elif args.cmd == 'map':
    demux = 'R1_93'
    cmdTmpl = 'mp7butler.py -c %s l2demuxpp %s'

    cmd = cmdTmpl % (connections,demux)
    
    print cmd
    subprocess.call(cmd.split())
    
