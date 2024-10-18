#!/bin/bash
#SBATCH -o %x-%J-SEQ.out         
#SBATCH -e %x-%J-SEQ.error       
#SBATCH --time=0-00:05:00    
#SBATCH --exclusive          
#SBATCH -n 16                 
#SBATCH --mem-per-cpu 1G    

gcc -pg -fopenmp -o knn knn.c -lm

time ./knn

gprof knn gmon.out > gprof_sequential.txt