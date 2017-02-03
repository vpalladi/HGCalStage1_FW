#!/bin/env python
'''
Create a board buffer data file.
'''

import logging

from mp7.tools.log_config import initLogging
import mp7.tools.helpers as hlp
import mp7.tools.buffers as buffers
from mp7 import BoardDataFactory, BoardData, Frame, LinkData
from mp7.tools.cli_utils import IntListAction

# import mp7.tools.dataio as dataio
import sys
import argparse

# ---------------------------------------------------------
def checkAlignment( buffers ):
    allPackets = set(map(tuple,[hlp.findPackets(buf.second) for buf in buffers]))



    if len(allPackets) != 1:
        logging.error('Format error? Packets are not aligned')
        sys.exit(-1)
    return allPackets.pop()

# ---------------------------------------------------------
def checkSizeSpacing( packets, size, spacing ):
    
    # print packets
    good = []

    # Check size first
    for i,p in enumerate(packets):
        s = p[1]-p[0]
        if s == size:
            good.append(p)
        else:
            logging.warning(' pkt %d: start %s end %s - size=%s',i,p[0],p[1],s)

    p0 = packets[0]
    for i,p in enumerate(packets[1:]):
        d = p[0]-p0[0]
        # s = p[1]-p[0]
        if d != spacing :
            logging.warning(' pkt %d-%d distance %d',i+1, i,d)
        p0 = p

    return good

# ---------------------------------------------------------
if __name__ == "__main__":

    # logging initialization
    initLogging( logging.DEBUG )
    
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    subparsers = parser.add_subparsers(dest = 'cmd')
    subp = subparsers.add_parser('single')
    subp.add_argument('path')

    args = parser.parse_args()

    if args.cmd == 'single':
        logging.notice('Analysing %s', args.path)
        data = BoardDataFactory.generate(args.path)

        packets = checkAlignment(data)

        print packets

        good = checkSizeSpacing(packets, 41, 54)

        #     print list(data[0])[b]

        for b,e in good:

            
            # Gather headers from all chans
            s = set([l.second[b].data & 0xfff for l in data])

            if len(s) != 1:
                logging.error('Header error: bunch crossing id non aligned')

            bxId = s.pop()
            logging.info("Packet header: bx id %d", bxId)

            # Loop over channels and frames
            
            nonzero = []
            for l in data:
                k,frames = l.first, l.second
                for j in xrange(b+1,e):
                    if frames[j].data == 0x10001000:
                        continue
                    nonzero.append( (k,j,frames[j].data) )
                    # print [ (j,l.second[j]) for l in data if l.second[j].data == '0x10001000' ]

            for k,j,d in nonzero:
                print k,j,hex(d)


