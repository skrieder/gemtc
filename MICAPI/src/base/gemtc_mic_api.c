#include "gemtc_types.h"
#include "gemtc_mic_api.h"
#include "super_kernel.h"
#include "QueueJobs.h"
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>


// TODO: Move all of this ======================
Queue newJobs, finishedJobs;


int* kill_p;
int total_workers;
pthread_t *worker_threads;
// =============================================

void MIC_gemtcSetup(int QueueSize, int workers) {

	// Initialize Queues
	newJobs = CreateQueue(QueueSize);
	finishedJobs = CreateQueue(QueueSize);

	kill_p = malloc(sizeof(int));
	*kill_p = 0;
	total_workers = workers;

	// Say hello to MIC
	#pragma offload_transfer target(mic:MIC_DEV)


	// TODO: Free this resource
	SuperKernelParameter_t *val = malloc(sizeof(SuperKernelParameter_t)); 
	val->incoming = newJobs;
	val->results = finishedJobs;
	val->kill = kill_p;

	// Launch threads
	worker_threads = malloc(sizeof(pthread_t) * total_workers);
	int t;
	for(t=0;t<total_workers;t++){
		pthread_create(&worker_threads[t], NULL, super_kernel, (void *)val);
	}  
}
void MIC_gemtcCleanup() {
	*kill_p = 1;

	DisposeQueue(newJobs);
	DisposeQueue(finishedJobs);

	int t;
	for (t=0; t<total_workers;t++) {
		pthread_join(worker_threads[t], NULL);
	}

	free(worker_threads);
	free(kill_p);
}

void MIC_gemtcPush(int taskType, int Threads, int ID, void *params) {
  JobDescription_t* job = (JobDescription_t*) malloc(sizeof(JobDescription_t));
  job->JobType = taskType;
  job->numThreads = Threads;
  job->params = params;
  job->JobID = ID;

  Enqueue(job, newJobs);
}
void MIC_gemtcPoll(int *ID, void **params) {
	JobDescription_t* job;

	job = MaybeFandD(finishedJobs);//returns null if empty

	if(job==NULL){
		*ID=-1;
		*params=NULL;

	} else {

		*ID = job->JobID;
		*params = job->params;

		free(job);
	}
}