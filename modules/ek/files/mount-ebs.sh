#!/bin/bash -ex
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Why we don't manage this
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`

# self-attach ebs volume
aws --region ${availability_zone} ec2 attach-volume --volume-id ${volume_id} --instance-id $INSTANCE_ID --device ${device_name}

# self-attach ebs volume:
while :
do
    if lsblk | grep ${lsblk_name}; then
        echo "attached"
        break
    else
        echo "looping"
        sleep 5
    fi
done

# create fs if needed
if file -s ${device_name} | grep ext4; then
    echo "skipping create fs"
else
    echo "creating fs"
    mkfs -t ext4 ${device_name}
fi

mkdir -p ${elasticsearch_data_dir}
mount ${device_name} ${elasticsearch_data_dir}
echo "${device_name} ${elasticsearch_data_dir} ext4 defaults,nofail 0 2" | tee -a /etc/fstab
chown -R elasticsearch. ${elasticsearch_data_dir}
