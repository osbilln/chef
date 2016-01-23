#!/usr/bin/ruby1.9.1

require 'aws-sdk'
require 'logger'
require 'json'
require 'date'

# resize the instance specified by instance_id to the passed in itype value
if ARGV.count < 2
  puts "instance_resize.rb usage: <instance_id> <itype>"
  exit
end

instance_id = ARGV[0]
itype = ARGV[1]
log = Logger.new("/home/ubuntu/dr_control/logs/#{instance_id}_resize.log")

client = client = Aws::EC2::Client.new(region: 'us-west-2')
ec2 = Aws::EC2::Resource.new(client: client) # keys are picked up from calling users AWS keys ~/.aws/config

# check size and status of instance
instance = ec2.instance(instance_id)
current_itype = instance.instance_type

if itype == current_itype
  log.info("instance: #{instance_id} size already matches specified size: #{current_itype}")
  puts "success"
  exit(0)
end

instance.stop # stop instance

# wait until instance has stopped up to 10 minutes checking every 10 seconds 
ec2.client.wait_until(:instance_stopped, {:instance_ids => [ instance_id ]}) do |w|
  # seconds between each attempt
  w.interval = 10
 
  # maximum number of polling attempts before giving up
  w.max_attempts = 60
end

instance = ec2.instance(instance_id) # reinitialize instance resource to get current state
if instance.state.name != 'stopped'
  log.info("instance: #{instance_id} failed to stop! state => #{instance.state.name}")
  exit(1)
end

# change instance type
instance.modify_attribute(instance_type: { value: itype })

instance.start # restart instance

# wait until instance has stopped up to 10 minutes checking every 10 seconds 
ec2.client.wait_until(:instance_running, instance_ids: ["#{instance_id}"]) do |w|
  # seconds between each attempt
  w.interval = 10
 
  # maximum number of polling attempts before giving up
  w.max_attempts = 60
end

instance = ec2.instance(instance_id) # reinitialize instance resource to get current state
if instance.state.name == 'running'
  log.info("instance: #{instance_id} up and running")
  puts "success"
else
  log.info("instance: #{instance_id} failed to start giving up waiting, current_state: #{instance.state.name}")
end





