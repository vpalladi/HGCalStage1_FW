#!/bin/env python
'''
Script for testing the Layer 1 -> Layer 2 patch panel mapping
'''
import mp7
import logging
from mp7.tools.log_config import initLogging

import math
from random import shuffle
import mp7.tools.helpers as hlp
import mp7.tools.data as data

import sys
import argparse
import uhal
import subprocess
import xml.etree.ElementTree as ET
import os
import re

from mp7.cli_core import CommandAdaptor
from mp7.tools.cli_utils import IntListAction


def parseOptions():
    
    import optparse
    usage = '''
%prog name [options]
'''
    
    connectionfile =  'file://etc/mp7/schroff_L2P5.xml;'
    parser = optparse.OptionParser( usage )
    parser.add_option('-c','--connections', default=connectionfile, help='Uhal connection file')
    parser.add_option('-p','--patchtest', dest='patch',default=False, help='Test fibre mapping/patching L1->L2',action='store_true')
    parser.add_option('-a','--analyse', dest='analyse', help='Analyse Rx buffers on all boards', action='store_true')
    
    opts, args = parser.parse_args()
    return opts,args

#linkmap=dict(zip(range(0,72),[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
#17,18,19,20,21,22,23,24,26,27,25,29,28,30,31,32,33,34,35,61,
#60,63,62,65,64,67,66,69,68,70,71,49,48,51,50,53,52,55,54,57,
#56,58,59,37,36,39,38,41,40,42,43,44,46,45,47]))


yes = set(['yes','y'])
no = set(['no','n'])

initLogging(logging.INFO)

opts, args = parseOptions()
hlp.logo()

#uhal.setLogLevelTo(uhal.LogLevel.INFO)

logging.notice('Running L1->L2 patch panel test... Hold tight!')

boards = []
for connection in ET.parse(os.path.expandvars(opts.connections.split('//')[1].split(';')[0])).getroot().findall('connection'):
    id = connection.get('id')
    boards.insert(0, id)
boards.reverse()

tmtmap=dict(zip(boards,range(0,11)))


logging.info('Connections file is: %s' % os.path.expandvars(opts.connections.split('//')[1].split(';')[0]))
logging.info('Using the following MP7-XEs:')
logging.info('%s' % ', '.join(boards))

if opts.analyse:

    numCTP7=4

    logging.info('Analysing Rx buffers from all boards...')
    frmChk=0
    ppBox = ['0a','0b','0c','0c','0b','0a']  #,'0a','0b','0c','0a','0b','0c']

    caloSliceID =     ['c0','c1','c2','c3','c2','c3', \
                       'c4','c5','c4','c5','c6','c7', \
                           #
                       'c6','c7','c8','c9','c8','c9', \
                       'ca','cb','ca','cb','cc','cd', \
                           #
                       'cc','cd','ce','cf','ce','cf', \
                       'd0','d1','d0','d1','d2','d3', \
                           #
                       'd2','d3','d4','d5','d4','d5', \
                       'd6','d7','d6','d7','d8','d9', \
                           #
                       'd8','d9','da','db','da','db', \
                       'dc','dd','dc','dd','de','df', \
                           #
                       'de','df','e0','e1','e0','e1', \
                       'e2','e3','e2','e3','c0','c1']

    portID =     [1,2,3,4,5,6,7,8,9,10,11,12,\
                  1,2,3,4,5,6,7,8,9,10,11,12,\
                  1,4,2,3,6,5,7,8,9,10,11,12, \
                  14,13,16,15,18,17,19,20,21,23,22,24,\
                  14,13,16,15,18,17,20,19,22,21,23,24,\
                  14,13,16,15,18,17,20,19,22,21,23,24]
    #ctp7IterMap = dict(zip(range(1,13),[1,2,7,8,3,4,9,10,5,6,11,12]))
    #for link in range(0,72):
    #    print link, '1'+ppBox[int(linkmap[link]/12)]+'0'+str((linkmap[link]%12)+1+(link/36)*12)+\
    #    '0'+str(((int((linkmap[link]+2)/2)-1)%3)+1)+'0'+'00'

    #shuffle(portID)

    boardErrs=[]
    totErrcnt=0
    goodLinks=0
    totLinks=0
    totGoodPackets=0
    totPackets=0
    captures=0
    header=0
    correctheader=0

    #loop over boards
    for board in boards:
        boardErrcnt=0
        numGoodPackets=0
        numPackets=0
        goodBoardLinks=0
        boardLinks=0
        boardLinkErrs=0
        #loop over patch panel input rows
        fileErr=False
        filename='test8june/good/mp'+str(boards.index(board))+'/rx_summary.txt'
        if not os.path.exists(filename):
            logging.warning('File %s not found!' % filename)
            continue
        captures+=1
        datalist = mp7.BoardDataFactory.readFromFile(filename)
        #logging.info('Opening file: %s' % 'ppcap/mp'+str(boards.index(board))+'/rx_summary.txt')
        #data = datalist[0]
        #loop over links (LOGICAL / CTP7 side)
        for link in xrange(0,72):
            linkCheck=False
            linkErr=False
            linkGood=False
            numLinkErrs=0
            linkPackets=0
            boardLinks+=1
            vpayload=0
            header=0
            correctheader=0
            #loop over packets in links (MAPPED / MP7 side)
            for packet in data.findPackets(datalist[link]):
                goodPacket=False
                framenum = packet[0]
                if packet[0]==0:
                    continue
                numPackets+=1
                totPackets+=1
                packetErr=False
                #loop over frames in valid packets in given MP7 link buffer
                for frameiter in xrange(packet[0],packet[1]+1):
                    frame = datalist[link][frameiter]
                    # here payload is 9 chars e.g. 10a010100 for Box A, Input Port 1, from CTP7 card 1, Fibre 0
                    # first byte is data valid, 1b-8b is payload
                    vpayload = str(int(frame.valid))+'v'+hex(frame.data)[2:].zfill(8)
                    if framenum == packet[0]:
                        header = vpayload
                        correctheader =  '1v'+caloSliceID[link]+format(boards.index(board),"x").zfill(2) 
                        if '1v'+caloSliceID[link]+format(boards.index(board),"x").zfill(2) in vpayload:
                            goodPacket=True
                            #count good packets on this link
                            linkPackets+=1
                            header=0
                            correctheader=0
                        else:
                            logging.error('Incorrect header: %s != %s', correctheader,header)
                            #linkCheck=True
                        #continue
                    if goodPacket and framenum is not packet[0]:
                        #determine expected payload
                        if opts.patch:
                            correct = '1'+'v'+ppBox[int(link/12)]+format(portID[link],"x").zfill(2)+\
                                caloSliceID[link]+'0'+hex(boards.index(board))[2:]
                        elif opts.analyse:
                            vpayloadmask = 0x41FF41FF & frame.data
                            etaindex  = framenum-packet[0] if ((framenum-packet[0]) < 29) else ((framenum-packet[0])+1)
                            phiindex0 = 0x7 & ((2*int(math.floor(link/2))+1)) if  ((framenum-packet[0]) < 29) else 0
                            phiindex1 = 0x7 & ((2*int(math.floor(link/2))+2)) if  ((framenum-packet[0]) < 29) else 0
                            correct   = '1v' + format(((link%2)<<30) + ((phiindex1)<<22) + (etaindex<<16) + ((link%2)<<14) + (phiindex0<<6) + etaindex,"x").zfill(8)
                            vpayload = str(int(frame.valid))+'v'+format(vpayloadmask,"x").zfill(8)
                            #print 'vpayload %s, correct %s etaindex %s phiindex0 %s phiindex1 %s' % (vpayload, correct, etaindex, phiindex0, phiindex1)
                        if not vpayload == correct:
                            #if not linkErr:
                            logging.error('Box %s Input %s CTP7 %s Fibre %d (%s) Link %d Frame %d does not match. Expected: %s, seen: %s' 
                                          % (ppBox[int(link/12)],format(portID[link],"x").zfill(2),
                                             caloSliceID[link],boards.index(board)+1,board,link,framenum, correct, vpayload))
                            boardErrcnt+=1
                            totErrcnt+=1
                            fileErr=packetErr=linkErr=True
                            numLinkErrs+=1
                        #if vpayload == correct and framenum is not packet[0]:
                            #linkGood=True
                        #    if not linkCheck:
                        #        logging.INFO('Link %d Good! vpayload = %s, correct = %s',link,vpayload,correct)
                        #    linkCheck=True
                        #increment number of frames checked
                        frmChk+=1
                    #increment link buffer frame index
                    framenum +=1
                if goodPacket and not packetErr:
                    numGoodPackets+=1
                #set goodPacket to False before moving onto next valid packet
                goodPacket=False
            #if not numLinkErrs:
            #    linkGood=True
            if not linkPackets:
                logging.error('No valid packets found from Box %s Input %s CTP7 %s Fibre %d Link %d (file: %s)' % (ppBox[int(link/12)],
                                      format(portID[link],"x").zfill(2),caloSliceID[link],boards.index(board)+1,link,filename))
            if linkPackets and not numLinkErrs:
                goodLinks+=1
                goodBoardLinks+=1
            totLinks+=1
            boardLinkErrs+=numLinkErrs
        if fileErr or not numGoodPackets: 
            logging.warning('Errors found in file %s' % filename)
        if not numGoodPackets:
            logging.warning('Good packets found for MP %d board %s:\t %d/%d \t Good links: %d/%d \tLink errors: %d' % (boards.index(board)+1, board, numGoodPackets,
                                                                                              numPackets,goodBoardLinks,boardLinks,boardLinkErrs))
        else:
            logging.notice('Good packets found for MP %d board %s:\t %d/%d \t Good links: %d/%d \tLink errors: %d' % (boards.index(board)+1, board, numGoodPackets,
                                                                                              numPackets,goodBoardLinks,boardLinks,boardLinkErrs))
        boardErrs.append(boardErrcnt)
        totGoodPackets+=numGoodPackets
        #break    

    #print out test summary
    for board in boards:
        if not boardErrs[boards.index(board)]:
            logging.notice('Board error count for MP  %d:     \t %d' % (boards.index(board)+1,boardErrs[boards.index(board)]))
        else:
            logging.warning('Board error count for MP  %d:      \t %d' % (boards.index(board)+1,boardErrs[boards.index(board)]))
    
    if not totErrcnt:
        logging.notice('Total error count:\t %d errors found from %d frames checked' % (totErrcnt, frmChk))
    else:
        logging.warning('Total error count:\t %d errors found from %d frames checked' % (totErrcnt, frmChk))

    logging.notice('SUMMARY: %d/%d good packets on %d/%d good links checked from %d sets of captures on %d boards' % (totGoodPackets,totPackets,goodLinks,totLinks,captures,len(boards)))

