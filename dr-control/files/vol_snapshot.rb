#!/usr/bin/ruby1.9.1

require 'logger'
require 'json'
require 'date'

# snaphot volume_id keeping last 2 days
if ARGV.count < 2
  puts "vol_snapshot.rb usage: <volume_id> <snapshot name prefix>"
  exit
end

volume_id = ARGV[0]
snapshot_name_prefix = ARGV[1]
snapshot_description = snapshot_name_prefix + " volume"
log = Logger.new("/home/ubuntu/dr_control/logs/#{snapshot_name_prefix}_vol_snapshot.log")
date = Time.now.strftime("%Y%m%d")
snapshot_name = "#{snapshot_name_prefix}_#{date}" # add date to snapshot name prefix

# create snapshot
log.info("aws command => aws ec2 create-snapshot --volume-id #{volume_id} --description '#{snapshot_description}'")
snapshot = `aws ec2 create-snapshot --volume-id #{volume_id} --description '#{snapshot_description}'`
snapshot_id = JSON.parse(snapshot)["SnapshotId"]
log.info("snapshot: #{snapshot_id} created from volume: #{volume_id}")

# tag the snapshot
log.info("aws command => aws ec2 create-tags --resources #{snapshot_id} --tags Key=Name,Value=#{snapshot_name}")
`aws ec2 create-tags --resources #{snapshot_id} --tags Key=Name,Value=#{snapshot_name}`

# delete snapshot from 2 days ago
past_date = (DateTime.now - 2).strftime("%Y%m%d")

# find snapshot from past_date
log.info("aws command => aws ec2 describe-snapshots --filters Name=tag-value,Values=#{snapshot_name_prefix}_#{past_date}")
manifest = `aws ec2 describe-snapshots --filters Name=tag-value,Values=#{snapshot_name_prefix}_#{past_date}`
snapshots =  JSON.parse(manifest)["Snapshots"]

if snapshots.empty?
  log.info("snapshot from 2 days ago not found")
else
  # pull snapshot id
  old_snapshot_id = snapshots[0]["SnapshotId"]
  log.info("aws command => aws ec2 delete-snapshot --snapshot-id #{old_snapshot_id} ")
  `aws ec2 delete-snapshot --snapshot-id #{old_snapshot_id}`
end