#!/bin/bash
dir="/backups"
pattern="world-*"
threshold_mem_size=5368709120

dir_disk_size() {
        du_ret=$(du -sb "$1")
        spilt=($(echo "$du_ret" | tr " /" "\n"))
        size=$((${spilt[0]}))
        return $size
}

remove_latest() {
        echo "[$(find $dir -name "$pattern" -printf '%T+ %p\n' | sort | head -n 1)] will be deleted."
        rm -rf `find $dir -name "$pattern" -printf '%T+ %p\n' | sort | head -n 1`
        echo "Removing success."
}

dir_disk_size $dir
ret=$size


#if [ `expr $ret > $threshold_mem_size` ]; then
if (( $ret > $threshold_mem_size )); then
        echo "out of memory [$ret]"
        echo "freeing up space..."
        remove_latest
else
        echo "enough memory left [$ret]"
fi
