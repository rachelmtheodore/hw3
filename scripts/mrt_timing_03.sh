#!/bin/bash

# To specify the number of iterations, enter the number following the name of the script in terminal.
# This will assign the number as variable $1 for the script.
# For example, "scripts/mrt_timing_03.sh 10" will specify running the loop 10 times.

Iteration=$(seq $1)

for iteration in $Iteration
do
	make_random_timing.py -num_stim 3 -num_runs 1 \
	-run_time 300 \
	-stim_labels A B C \
	-num_reps 20 \
	-prefix mrt_consec_times/stimt_${iteration} \
	-stim_dur 2 \
	-min_rest 1 \
	-max_rest 5 \
	-seed ${iteration} \
	-max_consec 1
	3dDeconvolve \
	-nodata 300 1 -polort 1 \
	-num_stimts 3 \
	-stim_times 1 mrt_consec_times/stimt_${iteration}_01_A.1D "GAM" -stim_label 1 "A" \
	-stim_times 2 mrt_consec_times/stimt_${iteration}_02_B.1D "GAM" -stim_label 2 "B" \
	-stim_times 3 mrt_consec_times/stimt_${iteration}_03_C.1D "GAM" -stim_label 3 "C" \
	-gltsym "SYM: A -B" -gltsym "SYM: A -C" \
	> mrt_consec_times/out_${iteration}.txt
	efficiency=`scripts/efficiency_parser.py mrt_consec_times/out_${iteration}.txt`
	echo "$efficiency $iteration" >> results/results.mrt.consec.txt
done

# We've now created a file in the results/replicate directory that shows the output of the efficiency script (vector 1)
# and the corresponding random seed (vector 2). Now we'll sort this file (results.txt) by efficiency.
# In the 3dDeconvulve output, lower numbers indicate greater efficiency, because lower numbers
# indicate lower standard error.
# This chunk will save the sorted output to a new file, and then print the top rows of the new
# (sorted) file.
cat results/results.mrt.consec.txt | sort -n -k 1 > results/results.mrt.consec.sort.txt
head results/results.mrt.consec.sort.txt

# Notes for the subroutines; need to update to include 3dDeconvulve.
# REFgen; AFNI program to generate Random Stimulus Functions.
# Arguments include:
# -nt; number of volumes.
# -num_stimts; number of stimulus types.
# -nreps; number of trials for each condition; the number of -nreps should equal the number identfied
# in -num_stimts.
# -seed; sets random seed; manually setting this will promote reproducibility.
# -prefix; specifies prefix in filename for created files; defaults filename includes identifer from -nreps
# and .1D suffix (e.g., *1.1D for -nreps 1 20).

# make_stim_times.py; Python program to create local timing files, which tell AFNI when stimuli
# occur relative to the start of each run.
# Each line == 1 run; different lines == different runs.
# Arguments include:
# -files; name of files from RSFgen.
# -prefix; filenames for the to-be-created files.
# -nt; number of volumes.
# -tr; time of TR in seconds.
# -nruns; number of runs.