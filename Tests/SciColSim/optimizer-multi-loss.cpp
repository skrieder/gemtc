
/*
  optimizer:multi_loss() packaged as a simple leaf function
*/

#include <cstdio>
#include "optimizer.cpp"
#include "timers.h"

// #define LOG_LEAF_CALLS
#ifdef LOG_LEAF_CALLS

static void leaf_report(char* token, int seed)
{
  time_t t = time(NULL);
  printf("leaf call: %s: seed: %i time: %i\n", token, seed, (int) t);
}

#else
#define leaf_report(t,s)
#endif

/**
   Simple wrapper for multi_loss()
   Creates Universe, calls multi_loss(), packs up results
 */
void optimizer_multi_loss(const char* graph_file,
                          // params0
                          double alpha_i,  double alpha_m, double beta,
                          double gamma,    double delta,   int target,
                          // params1
                          int n_epochs, int n_steps, int n_reruns,
                          // random seed
                          int seed,
                          // outputs
                          double** result, int* size)
{
  int identify_failed = 0;
  Universe* universe[1];
  universe[0] = new Universe(graph_file, n_epochs, n_steps, n_reruns,
                             identify_failed, target, i2string(0));
  universe[0]->set_verbose_level(0);
  srand(seed);
  update_id = seed;
  double Results[100];
  int Counters[(int) n_reruns];

  operation = 'm';
  Nworkers = 1;

  // Apparently a short copy of params0
  double x[5] = { alpha_i, alpha_m, beta, gamma, delta };

  // Call the real user function
  multi_loss(NO_DISPATCH_GROUP, universe, NO_DISPATCH_QS, Results, Counters, x);

  // Pack up results
  int N = universe[0]->get_reruns();
  *size = N;
  *result = new double[N];
  for(int i=0; i<N; i++)
    (*result)[i] = Results[i];

  delete universe[0];
}

/**
 *  Pack output as a Tcl list (space-separated string)
 *  If summarize is true, return summary statistics in Tcl list:
 *               [ <n samples>, <mean> ,<variance * n> ]
 *  Otherwise return all of the data points
 */
char* optimizer_multi_loss_tcl(const char *graph_file, int summarize,
                               //params0
                               double alpha_i,  double alpha_m, double beta,
                               double gamma,    double delta,   int target,
                               // params1
                               int n_epochs, int n_steps, int n_reruns,
                               // random seed
                               int seed)
{
  double* values;
  int size;
  TIMER_DECLARE(ml_timer);

  static int setup = 0;

  printf("ENTERING\n");
  if(setup == 0) {
      printf("INIITALING SETUP\n");
      gemtcSetup(12800, 0);
  }
  setup++;

  leaf_report((char*) "start", seed);

  TIMER_START(ml_timer);
  optimizer_multi_loss(graph_file, alpha_i, alpha_m, beta, gamma, delta, target,
                       n_epochs,  n_steps,  n_reruns, seed,
                       &values, &size);
  TIMER_END(ml_timer);
#if DO_PROFILE >= PROFILE_INFO
  printf("optimizer_multi_loss(target=%i, "
         "alphai=%.3lf, alpham=%.3lf, beta=%.3lf, gamma=%.3lf, delta=%.3lf "
         "n_epochs=%i, n_steps=%i, n_reruns=%i): %.4fs\n", 
         target, alpha_i, alpha_m, beta, gamma, delta,
         n_epochs, n_steps, n_reruns, GET_TIMING(ml_timer));
#endif
  char* result = NULL;
  if (summarize) {
    double sum = 0;
    /* Calculate mean and variance * n */
    for (int i = 0; i < size; i++) {
      double x = values[i];
      sum += x;
    }

    double mean = sum / size;
    double M2 = 0; // variance * n
    for (int i = 0; i < size; i++) {
      double x = values[i];
      double diff = x - mean;
      M2 += diff * diff;
    }

    result = (char*) malloc(3*32*sizeof(char));
    sprintf(result, "%i %lf %lf", size, mean, M2);
  } else {
    result = (char*) malloc(size*32*sizeof(char));
    char* p = result;
    for (int i = 0; i < size; i++)
      p += sprintf(p, "%f ", values[i]);
  }

  leaf_report((char*) "finish", seed);
  delete values;
  return result;
}

