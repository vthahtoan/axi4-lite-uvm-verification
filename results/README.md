# Simulation result logs

Place the final logs from the two simulator servers here:

```text
results/
|-- cadence/
|   |-- directed.log
|   `-- random.log
`-- questa/
    |-- directed.log
    `-- random.log
```

Copy `directed.log` from each server's `work/directed_test/` directory and `random.log` from its `work/random_test/` directory into the matching simulator folder. Keep the original log contents. The project's `.gitignore` allows these four log paths.

The two existing `cadence/xcelium_*_summary.txt` files are selected excerpts from the successful Xcelium runs. They remain separate from the full logs. The four full logs have not been added yet.

For each published run, record the simulator version, test name, random seed, scoreboard counts, UVM error/fatal counts, and functional coverage from that run's log. Results can differ between simulators even when the seed number is the same.
