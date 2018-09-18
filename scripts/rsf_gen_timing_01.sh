#!/bin/bash

# To specify the number of iterations, enter the number following the name of the script in terminal.
# This will assign the number as variable $1 for the script.
# For example, "scripts/rsf_gen_timing_01.sh 10" will specify running the loop 10 times.

Iteration=$(seq $1)

for iteration in $Iteration
do
	RSFgen \
	-nt 300 \
	-num_stimts 3 \
	-nreps 1 20 \
	-nreps 2 20 \
	-nreps 3 20 \
	-seed ${iteration} \
	-prefix times/stim_${iteration}_
	make_stim_times.py \
		-files times/stim_${iteration}_*.1D \
		-prefix stimt_${iteration} \
		-nt 300 \
		-tr 1 \
		-nruns 1
	3dDeconvolve \
	-nodata 300 1 -polort 1 \
	-num_stimts 3 \
	-stim_times 1 times/stimt_${iteration}.01.1D "GAM" -stim_label 1 "A" \
	-stim_times 2 times/stimt_${iteration}.02.1D "GAM" -stim_label 2 "B" \
	-stim_times 3 times/stimt_${iteration}.03.1D "GAM" -stim_label 3 "C" \
	-gltsym "SYM: A -B" -gltsym "SYM: A -C" \
	> times/out_${iteration}.txt
	efficiency=`scripts/efficiency_parser.py times/out_${iteration}.txt`
	echo "$efficiency $iteration" >> results/results.txt
done

# We've now created a file in the results directory that shows the output of the efficiency script (vector 1)
# and the corresponding random seed (vector 2). Now we'll sort this file (results.txt) by efficiency.
# In the 3dDeconvulve output, lower numbers indicate greater efficiency, because lower numbers
# indicate lower standard error.
# This chunk will save the sorted output to a new file, and then print the top rows of the new
# (sorted) file.
cat results/results.txt | sort -n -k 1 > results/results.sort.txt
head results/results.sort.txt

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