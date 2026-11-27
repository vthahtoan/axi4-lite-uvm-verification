# Simulation results

- [Xcelium directed FIFO test](cadence/directed.log) recorded 17 writes and 18 reads.
- [Xcelium constrained-random FIFO test](cadence/random.log) recorded 200 operations with seed 12345.
- [Questa directed](questa/directed.log) and [Questa random](questa/random.log) are historical runs of the earlier AXI4-Lite register-bank project.

New runs produce `directed.log` in `work/directed_test/` and `random.log` in `work/random_test/`. Record the simulator version, seed, and tested revision when publishing a result.
