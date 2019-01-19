#!/bin/sh
#exec /sbin/setuser datanext java -jar /var/datanext/engine-bundled.jar --runner=FlinkRunner --flinkMaster=local >>/var/log/datanext.log 2>&1
exec /sbin/setuser datanext java -cp /var/datanext/engine-bundled.jar org.acidaes.datanext.DataFlowEngine --runner=FlinkRunner --flinkMaster=$MASTER_API --filesToStage=/var/datanext/engine-bundled.jar --grpcPort=$PORT 2>&1