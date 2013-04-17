#include "gemtc_types.h"
#include "gemtc_mic_api.h"
#include "super_kernel.h"
#include "QueueJobs.h"
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>


// TODO: Move all of this ======================
Queue newJobs, finishedJobs;

pthread_mutex_t enqueueLock;
pthread_mutex_t dequeueLock;

int* kill_p;
int total_workers;
pthread_t *worker_threads;
// =============================================

void MIC_gemtcSetup(int QueueSize, int workers) {
	// Initalize locks (perhaps internalize this in Queue?)
	pthread_mutex_init(&enqueueLock, NULL);
	pthread_mutex_init(&dequeueLock, NULL);

	// Initialize Queues
	newJobs = CreateQueue(QueueSize);
	finishedJobs = CreateQueue(QueueSize);

	kill_p = malloc(sizeof(int));
	*kill_p = 0;

	total_workers = workers;

	//Launch threads

	// TODO: Free this resource
	SuperKernelParameter_t *val = malloc(sizeof(SuperKernelParameter_t)); 
	val->incoming = newJobs;
	val->results = finishedJobs;
	val->kill = kill_p;

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

	pthread_mutex_destroy(&enqueueLock);
	pthread_mutex_destroy(&dequeueLock);

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

  pthread_mutex_lock(&enqueueLock);
  	Enqueue(job, newJobs);
  pthread_mutex_unlock(&enqueueLock);
}
void MIC_gemtcPoll(int *ID, void **params) {
	JobDescription_t* job;

	pthread_mutex_lock(&dequeueLock);  //Start Critical Section
		job = MaybeFandD(finishedJobs);//returns null if empty
	pthread_mutex_unlock(&dequeueLock); //End Critical Section

	if(job==NULL){
		*ID=-1;
		*params=NULL;

	} else {

		*ID = job->JobID;
		*params = job->params;

		free(job);
	}
}