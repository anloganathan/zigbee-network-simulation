BEGIN {
print("\n\n******** Network Statistics ********\n");
	energy_left[25];
	packet_sent[25];
	packet_recvd[25];
for(i=0;i<25;i++)
{
	energy_left[i] = 1.000000;
	packet_sent[i] = 0;
	packet_recvd[i] = 0;
}			

total_pkt_sent=0;
total_pkt_recvd=0;
pkt_delivery_ratio = 0;
total_hop_count = 0;
avg_hop_count = 0;
start = 0.000000000;
end = 0.000000000;
packet_duration = 0.0000000000;
recvnum = 0;
delay = 0.000000000;
sum = 0.000000000;
i=0;
total_energy_consumed = 0.000000;
}

{
state		= 	$1;
time 		= 	$3;

node_num	= 	$5;
energy_level 	= 	$7;
	

node_id 	= 	$9;
level 		= 	$19;
pkt_type 	= 	$35;
packet_id	= 	$41;
no_of_forwards 	=	$49;
 

if((state == "s") && (level=="AGT")) { 
	for(i=0;i<25;i++) {
		if(i == node_id) {
		packet_sent[i] = packet_sent[i] + 1; }
}
}else if((state == "r") && (level=="AGT")) { 
	for(i=0;i<25;i++) {
		if(i == node_id) {
		packet_recvd[i] = packet_recvd[i] + 1; }
}
}

# total hop counts
if ((state == "r") && (level == "RTR") ) { total_hop_count = total_hop_count + no_of_forwards; }

#Average End to End Delay


if (( state == "s") && ( level == "AGT" ))  { start_time[packet_id] = time; }

 if (( state == "r") && ( level == "AGT" )) {  end_time[packet_id] = time;  }
 else {  end_time[packet_id] = -1;  }

#Average Energy Consumption
if(state == "N") {
	for(i=0;i<25;i++) {
		if(i == node_num) {
					energy_left[i] = energy_level;
				}
			
			  }
}
}
 

END {
for(i=0;i<25;i++) {
printf("%d %d \n",i, packet_sent[i]) > "pktsent.txt";
printf("%d %d \n",i, packet_recvd[i]) > "pktrecvd.txt";
printf("%d %.6f \n",i, energy_left[i]) > "energyleft.txt";

total_pkt_sent = total_pkt_sent + packet_sent[i];
total_pkt_recvd = total_pkt_recvd + packet_recvd[i];
total_energy_consumed = total_energy_consumed +(1.000000-energy_left[i]);

}
printf("Total Packets Sent 		:	%d\n",total_pkt_sent);
printf("Total Packets Received 		:	%d\n",total_pkt_recvd);

pkt_delivery_ratio = (total_pkt_recvd/total_pkt_sent)*100;

printf("Packet Delivery Ratio 		:	%.2f%\n",pkt_delivery_ratio);

printf("The total hop counts are 	:	%d\n", total_hop_count);

avg_hop_count = total_hop_count/total_pkt_recvd;
printf("Average Hop Count 		:	%d hops\n", avg_hop_count);



#End to End Delay

for ( i in end_time ) {
 start = start_time[i];
 end = end_time[i];
 packet_duration = end - start;
 if ( packet_duration > 0 )  { sum += packet_duration; recvnum++; }
}
 
delay=sum/recvnum;

printf("Average End to End Delay 	:       %.9f ms\n", delay);



printf("Total Energy Consumed  		:       %.6f\n", total_energy_consumed);



printf("Energy Consumption is	        :       %.2f%\n", ((total_energy_consumed/(25*1.000000))*100.000000));
		
}
