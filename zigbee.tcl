 set val(chan)           Channel/WirelessChannel    ;# Channel Type
 set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
 set val(netif)          Phy/WirelessPhy/802_15_4
 set val(mac)            Mac/802_15_4
 set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
 set val(ll)             LL                         ;# link layer type
 set val(ant)            Antenna/OmniAntenna        ;# antenna model
 set val(ifqlen)         50                         ;# max packet in ifq
 set val(nn)             25                         ;# number of mobilenodes
 set val(rp)             AODV                       ;# routing protocol
 set val(x)		50
 set val(y)		50
 
 set val(nam)		zigbee_nam.nam
 set val(traffic)	ftp                        ;# ftp
 
 
 set appTime1            30.0	;# in seconds
 set appTime2            30.2	;# in seconds
 set appTime3            30.3	;# in seconds
 set stopTime            50	;# in seconds
 
 
 set ns_		[new Simulator]
 set tracefd     [open ./zigbee_trace.tr w]
 
 $ns_ trace-all $tracefd
 if { "$val(nam)" == "zigbee_nam.nam" } {
         set namtrace     [open ./$val(nam) w]
         $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
 }
 $ns_ use-newtrace
 $ns_ puts-nam-traceall {# nam4wpan #}		
 Mac/802_15_4 wpanNam namStatus on	
 
 
 # For model 'TwoRayGround'
 set dist(5m)  7.69113e-06
 set dist(9m)  2.37381e-06
 set dist(10m) 1.92278e-06
 set dist(11m) 1.58908e-06
 set dist(12m) 1.33527e-06
 set dist(13m) 1.13774e-06
 set dist(14m) 9.81011e-07
 set dist(15m) 8.54570e-07
 set dist(16m) 7.51087e-07
 set dist(20m) 4.80696e-07
 set dist(25m) 3.07645e-07
 set dist(30m) 2.13643e-07
 set dist(35m) 1.56962e-07
 set dist(40m) 1.20174e-07
 Phy/WirelessPhy set CSThresh_ $dist(15m)
 Phy/WirelessPhy set RXThresh_ $dist(15m)
 

 set topo       [new Topography]
 $topo load_flatgrid $val(x) $val(y)
 
 
 set god_ [create-god $val(nn)]
 
 set chan_1_ [new $val(chan)]
 

 
 $ns_ node-config -adhocRouting $val(rp) \
 		-llType $val(ll) \
 		-macType $val(mac) \
 		-ifqType $val(ifq) \
 		-ifqLen $val(ifqlen) \
 		-antType $val(ant) \
 		-propType $val(prop) \
 		-phyType $val(netif) \
 		-topoInstance $topo \
 		-agentTrace ON \
 		-routerTrace ON \
 		-macTrace ON \
 		-movementTrace OFF \
        -energyModel "EnergyModel" \
        -initialEnergy 1 \
        -rxPower 0.3 \
        -txPower 0.3 \
 		-channel $chan_1_
 
 for {set i 0} {$i < $val(nn) } {incr i} {
 	set node_($i) [$ns_ node]	
 	$node_($i) random-motion 0		;
 }
 
 source ./topology.scn
 $ns_ at 0.0 "$node_(23) NodeLabel PAN Coor";
 $ns_ at 0.0 "$node_(23) sscs startPANCoord";
 set curr 0.0
 for {set i 0} {$i < $val(nn) } {incr i} {
    if {$i!=23} {
     if {$i==2 || $i==7 || $i==24 || $i==6 || $i==19 || $i==12 || $i==5 || $i==21  } {
        $ns_ at $curr+0.5 "$node_($i) sscs startDevice 1";
    } else {
        $ns_ at $curr+0.5 "$node_($i) sscs startDevice 0";
    }
    }
    
 }
         
 
 proc ftptraffic { src dst starttime } {
    global ns_ node_
    set tcp($src) [new Agent/TCP]
    eval \$tcp($src) set packetSize_ 60
    set sink($dst) [new Agent/TCPSink]
    eval $ns_ attach-agent \$node_($src) \$tcp($src)
    eval $ns_ attach-agent \$node_($dst) \$sink($dst)
    eval $ns_ connect \$tcp($src) \$sink($dst)
    set ftp($src) [new Application/FTP]
    eval \$ftp($src) attach-agent \$tcp($src)
    $ns_ at $starttime "$ftp($src) start"
 }
 
 if { "$val(traffic)" == "ftp" } {
    puts "\nTraffic: ftp"
    #Mac/802_15_4 wpanCmd ack4data off
    set lowSpeed 0.2ms
    set highSpeed 0.5ms
    Mac/802_15_4 wpanNam PlaybackRate $lowSpeed
    $ns_ at [expr $appTime1+0.2] "Mac/802_15_4 wpanNam PlaybackRate $highSpeed"
    $ns_ at $appTime2 "Mac/802_15_4 wpanNam PlaybackRate $lowSpeed"
    $ns_ at [expr $appTime2+0.2] "Mac/802_15_4 wpanNam PlaybackRate $highSpeed"
    $ns_ at $appTime3 "Mac/802_15_4 wpanNam PlaybackRate $lowSpeed"
    $ns_ at [expr $appTime3+0.2] "Mac/802_15_4 wpanNam PlaybackRate 1ms"
    ftptraffic 23 15 $appTime1
    ftptraffic 11 8 $appTime2
    ftptraffic 1 23 $appTime3
    Mac/802_15_4 wpanNam FlowClr -p AODV -c tomato
    Mac/802_15_4 wpanNam FlowClr -p ARP -c green
    Mac/802_15_4 wpanNam FlowClr -p tcp -s 23 -d 15 -c blue
    Mac/802_15_4 wpanNam FlowClr -p ack -s 15 -d 23 -c blue
    Mac/802_15_4 wpanNam FlowClr -p tcp -s 11 -d 8 -c green4
    Mac/802_15_4 wpanNam FlowClr -p ack -s 8 -d 11 -c green4
    Mac/802_15_4 wpanNam FlowClr -p tcp -s 1 -d 23 -c cyan4
    Mac/802_15_4 wpanNam FlowClr -p ack -s 23 -d 1 -c cyan4
    $ns_ at $appTime1 "$node_(23) NodeClr blue"
    $ns_ at $appTime1 "$node_(15) NodeClr blue"
    $ns_ at $appTime1 "$ns_ trace-annotate \"(at $appTime1) ftp traffic from node 23 to node 15\""
    $ns_ at $appTime2 "$node_(11) NodeClr blue"
    $ns_ at $appTime2 "$node_(8) NodeClr blue"
    $ns_ at $appTime2 "$ns_ trace-annotate \"(at $appTime2) ftp traffic from node 11 to node 8\""
    $ns_ at $appTime3 "$node_(1) NodeClr blue"
    $ns_ at $appTime3 "$node_(23) NodeClr blue"
    $ns_ at $appTime3 "$ns_ trace-annotate \"(at $appTime3) ftp traffic from node 1 to node 23\""
}
 
 for {set i 0} {$i < $val(nn)} {incr i} {
 	$ns_ initial_node_pos $node_($i) 2
 }
 
 for {set i 0} {$i < $val(nn) } {incr i} {
     $ns_ at $stopTime "$node_($i) reset";
 }
 
 $ns_ at $stopTime "stop"
 $ns_ at $stopTime "puts \"\nNS EXITING...\""
 $ns_ at $stopTime "$ns_ halt"
 
 proc stop {} {
     global ns_ tracefd val env
     $ns_ flush-trace
     close $tracefd
     set hasDISPLAY 0
     foreach index [array names env] {
         #puts "$index: $env($index)"
         if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                 set hasDISPLAY 1
         }
     }
     if { ("$val(nam)" == "zigbee_nam.nam") && ("$hasDISPLAY" == "1") } {
 	    exec nam zigbee_nam.nam &
     }
 }
 
 puts "\nStarting Simulation..."
 $ns_ run

