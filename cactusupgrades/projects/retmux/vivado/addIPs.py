#!/usr/bin/python

import os
import shutil

TOPpath = './top_2016/top_2016.srcs/sources_1/ip'
FWpath = '../firmware/ip'

print '!!! WARNING !!!'

print 'This program will remove all your Xilinx IP cores in'+FWpath
print 'And will copy the new Xilinx IP cores in'+TOPpath
print ' ---- it will also update the IP core list in ./src/ip.txt'

raw_input('press a key to continue or Ctrl+c to escape (this message will be repeated twice)')
raw_input('press a key to continue or Ctrl+c to escape (this message will be repeated twice)')

lsFW  = os.listdir(FWpath)
lsTOP = os.listdir(TOPpath)

fIPs = open('./src/ip.txt', 'w')

for f in lsTOP :
    
    if f[0] != '.' :
        src = TOPpath+'/'+f
        dst = FWpath+'/'+f
        fIPs.write('/'+dst+'/'+f+'.xci\n') # first '/' needed in vivado
        #print src,dst
        if os.path.isdir(dst) :
            #print 'rmdir'+dst
            shutil.rmtree(dst)
        #print 'mkdir'+dst
        os.mkdir( dst ) # creates the directory for the specific IP
        lsTMP = os.listdir(src)
        for tmp in lsTMP :
            if tmp.endswith('.xci') :
                #print 'cp '+src+dst+'/'+f+'.xci'
                shutil.copyfile( src+'/'+tmp , dst+'/'+tmp )
                break
