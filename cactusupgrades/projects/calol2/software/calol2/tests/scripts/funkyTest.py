#!/bin/env python

print 'funkyTest'

import uhal
import mp7
import calol2

uhal.setLogLevelTo(uhal.LogLevel.NOTICE)

cm = uhal.ConnectionManager('file://${CALOL2_TESTS}/etc/calol2/connections-Schroff2.xml')

board = calol2.Controller(cm.getDevice('S2_B9_TUN'))

funky = board.hw().getNode('payload')

fmb = calol2.FunkyMiniBus(funky)

dump = {}
# fmb.unlock()
# for e in fmb:
    # dump[e.name()] =  e.read()
    # e.lock()