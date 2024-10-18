# FINAL PROJECT: OPENMP

## Overview

The Final Project involves the parallelization of the `knn.c` program, which implements the k-nearest neighbor algorithm (k-NN), a non-parametric supervised learning classifier. The program uses proximity to make classifications or predictions about data points based on their k-nearest neighbors.

The input files used are `pp_tra.txt` and `pp_tes.txt`, which contain training and test data. The original program is sequential, and the task is to parallelize it using OpenMP, measure the performance improvements, and analyze the speedup obtained by comparing sequential and parallel execution times.

We utilized `gprof` to profile the code and determine which parts of the program are the best candidates for parallelization. Below is a detailed explanation of the steps followed in the process.

---

## Sequential Code Execution

I started by running the original sequential code 5 times to calculate the average execution time.

Here is the command to run the sequential code :

```bash
sbatch runSEQUENTIAL.sh
```

The results are as follows:

| Run         | Time (Minutes:Seconds) |
| ----------- | ---------------------- |
| 1           | 4m0s                   |
| 2           | 4m4s                   |
| 3           | 4m2s                   |
| 4           | 4m1s                   |
| 5           | 4m3s                   |
| **Average** | **4m2s**               |

---

## Profiling with `gprof`

After running `gprof` on the sequential version of the program, we obtained the following flat profile:

![alt text](Final%20Project/Images/gprof1.png)

From this profile, it was clear that the following three functions take up the majority of the computation time:

- `calculate_distance`: 50.13%
- `calculate_distance_test`: 38.49%
- `merge`: 10.49%

---

## Initial Parallelization Attempt

### Naive Parallelization

I initially attempted to parallelize the functions `calculate_distance`, `calculate_distance_test`, and `merge` as these consumed the most execution time. However, the program ran **slower** than the sequential version, which indicated that my approach was incorrect.

### Detailed Call Graph from `gprof`

To better understand the bottleneck, I analyzed the call graph:

![alt text](Final%20Project/Images/gprof2.png)

From this, I realized that the functions `calculate_test`, `calculate_error`, and `mergeSort` were making recursive calls to `calculate_distance`, `calculate_distance_test`, and `merge`, respectively.

---

## Revised Parallelization Plan

### Step 1: Parallelizing `calculate_distance`

First, I parallelized the `calculate_error` function using OpenMP.

Here is the command to make a run with paralelized `calculate_error`function :

```bash
sbatch runOMP1.sh
```

The program was run 5 times, and the average execution time was as follows:

| Run         | 1 Thread | 2 Threads | 4 Threads | 8 Threads | 16 Threads |
| ----------- | -------- | --------- | --------- | --------- | ---------- |
| 1           | 4m0s     | 3m2s      | 2m29s     | 2m13s     | 2m4s       |
| 2           | 4m4s     | 3m3s      | 2m31s     | 2m11s     | 2m6s       |
| 3           | 4m2s     | 3m3s      | 2m30s     | 2m10s     | 2m2s       |
| 4           | 4m1s     | 3m1s      | 2m28s     | 2m14s     | 2m3s       |
| 5           | 4m3s     | 3m1s      | 2m28s     | 2m12s     | 2m1s       |
| **Average** | **4m2s** | **3m2s**  | **2m29s** | **2m12s** | **2m4s**   |
| **SpeedUp** | **1**    | **1.33**  | **1.62**  | **1.83**  | **1.95**   |

The results are better, paralelize parent functions was the good idea.

---

### Step 2: Parallelizing `calculate_test`

Next, I also parallelized the `calculate_test` function.

Here is the command to make a run with paralelized `calculate_test` and `calculate_error`:

```bash
sbatch runOMP12.sh
```

Below are the execution times for this version:

| Run         | 1 Thread | 2 Threads | 4 Threads | 8 Threads | 16 Threads |
| ----------- | -------- | --------- | --------- | --------- | ---------- |
| 1           | 4m0s     | 2m11s     | 1m10s     | 0m39s     | 0m24s      |
| 2           | 4m4s     | 2m10s     | 1m9s      | 0m40s     | 0m25s      |
| 3           | 4m2s     | 2m12s     | 1m10s     | 0m41s     | 0m25s      |
| 4           | 4m1s     | 2m12s     | 1m12s     | 0m39s     | 0m24s      |
| 5           | 4m3s     | 2m10s     | 1m9s      | 0m41s     | 0m24s      |
| **Average** | **4m2s** | **2m11s** | **1m10s** | **0m40s** | **0m24s**  |
| **SpeedUp** | **1**    | **1.85**  | **3.46**  | **6.05**  | **10.1**   |

---

### Step 3: Parallelizing `mergeSort` with OpenMP Sections

I then parallelized `mergeSort` using **OMP Sections**, but this did not improve the performance as expected.

Command to run the code :

```bash
sbatch runOMP12section.sh
```

Here are the execution times:

| Run         | 1 Thread | 2 Threads | 4 Threads | 8 Threads | 16 Threads |
| ----------- | -------- | --------- | --------- | --------- | ---------- |
| 1           | 4m0s     | 2m34s     | 1m28s     | 0m57s     | 0m39s      |
| 2           | 4m4s     | 2m36s     | 1m24s     | 0m58s     | 0m40s      |
| 3           | 4m2s     | 2m33s     | 1m26s     | 0m58s     | 0m39s      |
| 4           | 4m1s     | 2m33s     | 1m27s     | 0m56s     | 0m38s      |
| 5           | 4m3s     | 2m34s     | 1m25s     | 0m57s     | 0m40s      |
| **Average** | **4m2s** | **2m34s** | **1m26s** | **0m57s** | **0m39s**  |
| **SpeedUp** | **1**    | **1.57**  | **2.81**  | **4.24**  | **6.20**   |

Despite using OMP Sections to parallelize mergeSort, the performance improvement is limited compared to the original version, which only parallelized the calculate_error and calculate_test functions. The speedup observed across multiple threads is modest, and in some cases, it does not match the scaling we would expect with more threads.

The limitation likely stems from the way OMP Sections handles parallelization within mergeSort. Since the sections are not granular enough and the workload is unevenly distributed across threads, this creates inefficiencies that prevent full utilization of the available threads. As a result, this method does not yield significant improvements over the previous version.

---

### Step 4: Parallelizing `mergeSort` with OpenMP Tasks

I switched from OMP Sections to **OMP Tasks** for `mergeSort`, but this also did not yield significant improvements.

Command to run the code :

```bash
sbatch runOMP12task.sh
```

Here are the results:

| Run         | 1 Thread | 2 Threads | 4 Threads | 8 Threads | 16 Threads |
| ----------- | -------- | --------- | --------- | --------- | ---------- |
| 1           | 4m0s     | 2m14s     | 1m12s     | 0m42s     | 0m28s      |
| 2           | 4m4s     | 2m15s     | 1m12s     | 0m43s     | 0m28s      |
| 3           | 4m2s     | 2m13s     | 1m14s     | 0m42s     | 0m29s      |
| 4           | 4m1s     | 2m13s     | 1m14s     | 0m41s     | 0m27s      |
| 5           | 4m3s     | 2m15s     | 1m13s     | 0m42s     | 0m30s      |
| **Average** | **4m2s** | **2m14s** | **1m13s** | **0m42s** | **0m28s**  |
| **SpeedUp** | **1**    | **1.81**  | **3.32**  | **5.76**  | **8.07**   |

The switch from OMP Sections to OMP Tasks yielded slightly better performance, particularly with higher thread counts. However, the overall improvement still falls short of the performance achieved by parallelizing only the calculate_distance and calculate_distance_test functions.

While OMP Tasks provide more flexibility in task scheduling and work division across threads, this approach still does not fully exploit the parallel potential of the algorithm. The overhead of task creation and synchronization appears to limit performance gains. Nonetheless, OMP Tasks do bring the performance closer to the version that only parallelizes calculate_distance, indicating that they may be more effective than sections for finer-grained parallelism.

---

## Final Results and Conclusion

After parallelizing key functions in the program, the final results were as follows:

- **Speedup**: Speedup was calculated by comparing the sequential version (1 thread) to the best parallel version (16 threads). The highest speedup achieved was **10.1x** with 16 threads.
- **Performance**: The best performance improvements were observed when parallelizing the `calculate_error` and `calculate_test` functions. These parallelized functions provided significant reductions in execution time as the number of threads increased, with a clear trend of faster execution as more threads were utilized.

Here are the final execution times:

| Run         | 1 Thread | 2 Threads | 4 Threads | 8 Threads | 16 Threads |
| ----------- | -------- | --------- | --------- | --------- | ---------- |
| 1           | 4m0s     | 2m11s     | 1m10s     | 0m39s     | 0m24s      |
| 2           | 4m4s     | 2m10s     | 1m9s      | 0m40s     | 0m25s      |
| 3           | 4m2s     | 2m12s     | 1m10s     | 0m41s     | 0m25s      |
| 4           | 4m1s     | 2m12s     | 1m12s     | 0m39s     | 0m24s      |
| 5           | 4m3s     | 2m10s     | 1m9s      | 0m41s     | 0m24s      |
| **Average** | **4m2s** | **2m11s** | **1m10s** | **0m40s** | **0m24s**  |
| **SpeedUp** | **1**    | **1.85**  | **3.46**  | **6.05**  | **10.1**   |

### Speedup Analysis

The speedup achieved at each thread count shows significant improvements but deviates from the ideal linear speedup:

- **2 Threads**: A speedup of **1.85x** is close to the theoretical maximum of **2x**, indicating good parallelization efficiency at this stage.
- **4 Threads**: A speedup of **3.46x** shows continued improvement but already demonstrates a noticeable deviation from the optimal **4x** speedup. This deviation could be attributed to overhead costs such as thread management and synchronization.

- **8 Threads**: With a speedup of **6.05x**, we see that the gap between the actual and optimal speedup widens further. At **8 threads**, the optimal speedup would have been **8x**, but the performance gains diminish due to factors such as contention for shared resources or increased parallel overhead.

- **16 Threads**: The speedup of **10.1x** is the highest observed, but still significantly lower than the theoretical **16x** speedup. This discrepancy becomes even more apparent as the number of threads increases, indicating that as more threads are used, the efficiency of parallelization drops due to factors like diminishing returns from parallelism, thread contention, and increased overhead.

### Conclusion

The parallelization of functions such as `calculate_error` and `calculate_test` yielded substantial performance improvements, with the most noticeable gains as the number of threads increased. However, as the number of threads increases, we observe that the actual speedup deviates from the ideal speedup, particularly at higher thread counts. This highlights the challenges in achieving optimal parallel efficiency, especially with increasing overhead and diminishing returns.

While the parallelization was beneficial for some functions, recursive algorithms such as `mergeSort` did not exhibit the same level of improvement, underscoring the complexity of efficiently parallelizing certain parts of the program. Further exploration of optimization strategies or alternative parallelization techniques may be required to fully exploit multi-threading in those areas.
