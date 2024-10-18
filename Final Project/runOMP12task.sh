#!/bin/bash
#SBATCH -o %x-%J-OMP-12task.out         # Nom du fichier de sortie
#SBATCH -e %x-%J-OMP-12task.error       # Nom du fichier d'erreur
#SBATCH --time=0-00:20:00        # Temps d'exécution demandé
#SBATCH --exclusive              # Avoir un noeud exclusif pour pas fausser les temps d'execution 
#SBATCH -n 16                    # Nombre de tâches (processus MPI ou OpenMP threads si applicable)
#SBATCH --mem-per-cpu 1G         # Mémoire par CPU

# Compilation
gcc -pg -fopenmp -o knn_omp12task knn_omp12task.c -lm

# List of thread counts
thread_counts=(1 2 4 8 16)

# Loop over different numbers of threads
for num_threads in "${thread_counts[@]}"
do
    export OMP_NUM_THREADS=$num_threads
    
    echo "Running with OMP_NUM_THREADS=$num_threads:"
    
    time ./knn_omp12task
    
    echo "----------------------------------------"
done