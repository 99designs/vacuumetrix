#!/usr/bin/env ruby
## Elasticache stats
### David Lutz
### 2012-08-01
 
$:.unshift File.join(File.dirname(__FILE__), *%w[.. conf])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'config'
require 'Sendit'
require 'rubygems'
require 'fog'

startTime = Time.now.utc-180
endTime  = Time.now.utc-120

cw = Fog::AWS::CloudWatch.new(:aws_secret_access_key => $awssecretkey, :aws_access_key_id => $awsaccesskey, :region => $awsregion)
metrics_list = cw.list_metrics({
				'Namespace' => 'AWS/ElastiCache',
				'MetricName' => 'NetworkBytesIn'
		}).body['ListMetricsResult']['Metrics']


metrics_list.each do |met|
  next if met['Dimensions'].length==0

  cacheClusterId =  met['Dimensions'].first['Value']
  cacheNodeId = met['Dimensions'].last['Value']
  metricNames = ['GetMisses', 'GetHits', 'CurrConnections', 'CmdGet', 'CmdSet', 'CurrItems']
  statistic = 'Sum'
  unit = 'Count'

  metricNames.each do |metricName|
    response = cw.get_metric_statistics({
           'Statistics' => statistic,
           'StartTime' =>  startTime.iso8601,
           'EndTime'    => endTime.iso8601,
           'Period'     => 60,
           'Unit'       => unit,
           'MetricName' => metricName,
           'Namespace'  => 'AWS/ElastiCache',
           'Dimensions' => met['Dimensions']
	           }).body['GetMetricStatisticsResult']['Datapoints']

    metricpath = "AWScloudwatch.Elasticache." + cacheClusterId + "." + metricName + "." + cacheNodeId 
    begin
        metricvalue = response.first[statistic]
    rescue
        metricvalue = 0
    end
    metrictimestamp = endTime.to_i.to_s

    Sendit metricpath, metricvalue, metrictimestamp
  end
end



metrics_list.each do |met|
  next if met['Dimensions'].length==0

  cacheClusterId =  met['Dimensions'].first['Value']
  cacheNodeId = met['Dimensions'].last['Value']
  metricNames = ['CPUUtilization']
  statistic = 'Sum'
  unit = 'Percent'

  metricNames.each do |metricName|
    response = cw.get_metric_statistics({
           'Statistics' => statistic,
           'StartTime' =>  startTime.iso8601,
           'EndTime'    => endTime.iso8601,
           'Period'     => 60,
           'Unit'       => unit,
           'MetricName' => metricName,
           'Namespace'  => 'AWS/ElastiCache',
           'Dimensions' => met['Dimensions']
	           }).body['GetMetricStatisticsResult']['Datapoints']

    metricpath = "AWScloudwatch.Elasticache." + cacheClusterId + "." + metricName + "." + cacheNodeId
    begin
        metricvalue = response.first[statistic]
    rescue
        metricvalue = 0
    end
    metrictimestamp = endTime.to_i.to_s

    Sendit metricpath, metricvalue, metrictimestamp
  end
end



metrics_list.each do |met|
  next if met['Dimensions'].length==0

  cacheClusterId =  met['Dimensions'].first['Value']
  cacheNodeId = met['Dimensions'].last['Value']
  metricNames = ['BytesReadIntoMemcached', 'BytesUsedForCacheItems', 'BytesWrittenOutFromMemcached']
  statistic = 'Sum'
  unit = 'Bytes'

  metricNames.each do |metricName|
    response = cw.get_metric_statistics({
           'Statistics' => statistic,
           'StartTime' =>  startTime.iso8601,
           'EndTime'    => endTime.iso8601,
           'Period'     => 60,
           'Unit'       => unit,
           'MetricName' => metricName,
           'Namespace'  => 'AWS/ElastiCache',
           'Dimensions' => met['Dimensions']
	           }).body['GetMetricStatisticsResult']['Datapoints']

    metricpath = "AWScloudwatch.Elasticache." + cacheClusterId + "." + metricName + "." + cacheNodeId
    begin
        metricvalue = response.first[statistic]
    rescue
        metricvalue = 0
    end
    metrictimestamp = endTime.to_i.to_s

    Sendit metricpath, metricvalue, metrictimestamp
  end
end



