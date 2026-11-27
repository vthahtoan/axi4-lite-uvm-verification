database -open -shm -into directed.shm directed -default
probe -create -database directed tb_top.axi_if -all
run
exit
