#!/usr/bin/env ruby
## grab metrics from AWS cloudwatch 
### David Lutz
### 2012-07-10
### gem install fog  --no-ri --no-rdoc
 
$:.unshift File.join(File.dirname(__FILE__), *%w[.. conf])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'config'
require 'Sendit'
require 'rubygems'
require 'fog'
require 'json'

if ARGV.length != 1
        puts "I need one argument. The RDS instance name"
        exit 1
end

dimensionId = ARGV[0]

#AWS cloudwatch stats seem to be a minute or so behind

startTime = Time.now.utc-180
endTime  = Time.now.utc-120


metricNames = {	"CPUUtilization" 	=> "Percent", 
		"DatabaseConnections" 	=> "Count",
		"FreeStorageSpace" 	=> "Bytes",
		"ReadIOPS"		=> "Count/Second",
 		"ReadLatency"		=> "Seconds",
		"ReadThroughput"	=> "Bytes/Second",
		"WriteIOPS"		=> "Count/Second",
 		"WriteLatency"		=> "Seconds",
		"WriteThroughput"	=> "Bytes/Second",
	}

statisticTypes = 'Average'

cloudwatch = Fog::AWS::CloudWatch.new(:aws_secret_access_key => $awssecretkey, :aws_access_key_id => $awsaccesskey)


metricNames.each do |metricName, unit|

  response = cloudwatch.get_metric_statistics({
           'Statistics' => 'Average',
           'StartTime' =>  startTime.iso8601,
           'EndTime'    => endTime.iso8601, 
	   'Period'     => 60, 
           'Unit'       => unit,
	   'MetricName' => metricName, 
	   'Namespace'  => 'AWS/RDS',
	   'Dimensions' => [{
	                'Name'  => 'DBInstanceIdentifier', 
	                'Value' => dimensionId 
			}]
           }).body['GetMetricStatisticsResult']['Datapoints']

  metricpath = "AWScloudwatch.RDS." + dimensionId + "." + metricName 
  metricvalue = response.first["Average"]
  metrictimestamp = endTime.to_i.to_s

  Sendit metricpath, metricvalue, metrictimestamp
end
