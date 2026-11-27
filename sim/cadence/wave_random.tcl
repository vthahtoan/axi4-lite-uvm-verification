database -open -shm -into random.shm random -default
probe -create -database random tb_top.axi_if -all
run
exit
