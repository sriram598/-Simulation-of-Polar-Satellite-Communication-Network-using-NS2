BEGIN {
    max_node = 2000;
    nSentPackets = 0.0;		
    nReceivedPackets = 0.0;
    nDropPackets = 0.0;
    rTotalDelay = 0.0;
    max_pckt = 10000;

    idHighestPacket = 0;
    idLowestPacket = 100000;
    rStartTime = 10000.0;
    rEndTime = 0.0;
    nReceivedBytes = 0;

    for (i = 0; i < max_pckt; i++) {
        sent[i] = 0;
    }

    PKT_SIZE_CBR = 210;
}

{
    # Example trace line:
    # + 2 8 7 cbr 210 ------- 0 8.0 13.0 0 4

    strEvent = $1;  
    rTime = $2;
    from_node = $3;
    to_node = $4;
    pkt_type = $5;
    pkt_size = $6;
    flgStr = $7;
    flow_id = $8;
    src_addr = $9;
    dest_addr = $10;
    pkt_id = $11;

    if (pkt_type == "cbr") {

        # Update first/last times
        if (rTime < rStartTime) rStartTime = rTime;
        if (rTime > rEndTime) rEndTime = rTime;

        # Record packet send
        if (strEvent == "+" && pkt_size == PKT_SIZE_CBR) {
            source = int(from_node);
            potential_source = int(src_addr);

            if (source == potential_source) {
                nSentPackets += 1;
                rSentTime[pkt_id] = rTime;
                sent[pkt_id] = 1;
            }
        }

        # Record packet receive
        potential_dest = int(to_node);
        dest = int(dest_addr);

        if (strEvent == "r" && potential_dest == dest && pkt_size == PKT_SIZE_CBR && sent[pkt_id] == 1) {
            nReceivedPackets += 1;
            nReceivedBytes += pkt_size;
            rReceivedTime[pkt_id] = rTime;
            rDelay[pkt_id] = rReceivedTime[pkt_id] - rSentTime[pkt_id];
            rTotalDelay += rDelay[pkt_id];
        }

        # Record packet drop
        if (strEvent == "d" && pkt_size == PKT_SIZE_CBR) {
            nDropPackets += 1;
        }
    }
}

END {
    if (nSentPackets == 0) {
        print "Error: No packets were sent. Simulation trace might be empty or misconfigured.";
        exit 1;
    }

    rTime = rEndTime - rStartTime;
    rThroughput = (rTime > 0) ? nReceivedBytes * 8 / rTime : 0;
    rPacketDeliveryRatio = (nSentPackets > 0) ? (nReceivedPackets / nSentPackets) * 100 : 0;
    rPacketDropRatio = (nSentPackets > 0) ? (nDropPackets / nSentPackets) * 100 : 0;

    if (nReceivedPackets > 0) {
        rAverageDelay = rTotalDelay / nReceivedPackets;
    } else {
        rAverageDelay = 0;
    }

    printf("Throughput(bps): %.2f\n", rThroughput);
    printf("Average Delay(s): %.5f\n", rAverageDelay);
    printf("Sent Packets: %.2f\n", nSentPackets);
    printf("Received Packets: %.2f\n", nReceivedPackets);
    printf("Dropped Packets: %.2f\n", nDropPackets);
    printf("PDR(%%): %.2f\n", rPacketDeliveryRatio);
    printf("Drop Ratio(%%): %.2f\n", rPacketDropRatio);
    printf("Sim Time(s): %.5f\n", rTime);
    printf("Total Delay: %.5f\n", rTotalDelay);

    # Generate data files for plotting
    print 1, rThroughput > "throughput.xg"
    print 1, rPacketDeliveryRatio > "pdr.xg"
    print 1, rAverageDelay > "AverageDelay.xg"
}

