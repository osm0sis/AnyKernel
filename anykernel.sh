# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=DirtyV by bsmitty83 @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=maguro
device.name2=toro
device.name3=toroplus
device.name4=
device.name5=
} # end properties

# shell variables
ramdisk_compression=auto;
# determine the location of the boot partition
if [ "$(find /dev/block -name boot | head -n 1)" ]; then
  block=$(find /dev/block -name boot | head -n 1)
elif [ -e /dev/block/platform/sdhci-tegra.3/by-name/LNX ]; then
  block=/dev/block/platform/sdhci-tegra.3/by-name/LNX
else
  abort "! Boot img not found! Aborting!"
fi

# force expansion of the path so we can use it
block=`echo -n $block`;                                                 


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;

# File list
list="init.rc init.tuna.rc fstab.tuna"

## AnyKernel Slot device support
slot_device

# begin ramdisk changes


# init.rc
backup_file $overlay/init.rc;
replace_string $overlay/init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";
append_file $overlay/init.rc "run-parts" init;

# init.tuna.rc
backup_file $overlay/init.tuna.rc;
insert_line $overlay/init.tuna.rc "nodiratime barrier=0" after "mount_all /fstab.tuna" "\tmount ext4 /dev/block/platform/omap/omap_hsmmc.0/by-name/userdata /data remount nosuid nodev noatime nodiratime barrier=0";
append_file $overlay/init.tuna.rc "dvbootscript" init.tuna;

# fstab.tuna
backup_file $overlay/fstab.tuna;
patch_fstab $overlay/fstab.tuna /system ext4 options "noatime,barrier=1" "noatime,nodiratime,barrier=0";
patch_fstab $overlay/fstab.tuna /cache ext4 options "barrier=1" "barrier=0,nomblk_io_submit";
patch_fstab $overlay/fstab.tuna /data ext4 options "data=ordered" "nomblk_io_submit,data=writeback";
append_file $overlay/fstab.tuna "usbdisk" fstab;

# end ramdisk changes

write_boot;

## end install

