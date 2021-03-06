--- kern_switch.c.orig	2014-07-28 14:48:19.000000000 +0400
+++ kern_switch.c	2014-07-28 14:49:56.000000000 +0400
@@ -340,7 +340,21 @@
 	struct rqhead *rqh;
 	int pri;
 
+#ifdef SCHED_FBFS
+	if (td->td_priority >= PRI_MIN_IDLE) {					// >=224
+		pri = RQ_IDLE;							// 63
+	} else if (td->td_priority >= PRI_MIN_TIMESHARE) {			// >=120
+		pri = RQ_TIMESHARE;						// 62
+	} else if (td->td_priority >= PRI_MIN_REALTIME) {			// >=48
+		pri = min(RQ_MIN_REALTIME + td->td_priority - PRI_MIN_REALTIME,	// 61-12
+		RQ_MAX_REALTIME);
+	} else {
+		pri = td->td_priority / RQ_PPQ;					// 11-0
+	}
+#else
 	pri = td->td_priority / RQ_PPQ;
+#endif
+
 	td->td_rqindex = pri;
 	runq_setbit(rq, pri);
 	rqh = &rq->rq_queues[pri];
