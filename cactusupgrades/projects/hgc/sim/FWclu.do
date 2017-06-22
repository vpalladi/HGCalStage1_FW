


set output [exec ls "./data/"]; list

set inputs [split $output "\n"]; list

set fLatency [open "latency.csv" "w"]
puts -nonewline $fLatency "fileName,"
puts -nonewline $fLatency "sAcquired,"
puts -nonewline $fLatency "beginComputing,"
puts -nonewline $fLatency "endComputing,"
puts -nonewline $fLatency "beginSend,"
puts -nonewline $fLatency "endSend\n"
close $fLatency

set index -1
set max 100

foreach fIn $inputs {

    puts results/$fIn
    if { [file exists results/$fIn] == 0 } {
        set fLatency [open "latency.csv" "a"]
        puts -nonewline $fLatency $fIn
        puts -nonewline $fLatency ","
        close $fLatency
        vsim -gsourcefile=data/$fIn -gdestinationfile=results/$fIn -novopt work.TestBench -t 1ps -L dist_mem_gen_v8_0_11 -L blk_mem_gen_v8_3_5 -L unisims_ver -L unimacro_ver -L secureip
        run 1000 ns
        restart -f
    } else {
        puts results/$fIn
    }

    if { $index == $max } {
        break
    } elseif { $index != -1 } {
        incr index 1
    }
    
}

exit
#set samples {}
#for {set i 0} {$i < 10} {incr i} {
#    lappend samples $i
#}
#set samples { 0 1 2 3 4 5 6 }
#lappend samples "8"

#foreach {s} $samples {
#    vsim -gsourcefile=data/out_$s.mp7 -gdestinationfile=results/out_$s.mp7   -wlf wave.wlf -novopt work.TestBench -t 1ps -L dist_mem_gen_v8_0_11 -L blk_mem_gen_v8_3_5 -L unisims_ver -L unimacro_ver -L secureip
#    run 1000 ns
#    restart -f
#}
