#!/bin/bash
	
#
# -- SGE options :
#
	
#$ -S /bin/bash
#$ -cwd
#$ -q all.q
	
#
# -- the commands to be executed (programs to be run) :
#
	
/bin/hostname
/bin/date
/bin/sleep 60