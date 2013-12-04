//
//  main.cpp
//  optimizer
//
//  Created by Andrey Rzhetsky on 4/11/11.
//  Copyright 2011 University of Chicago. All rights reserved.
//

#define MAXNworkers 24
#define ALL_VISIBLE 1
#define DB if(verbose_level > 3)
int Nworkers=MAXNworkers;

// Add operation code to enable existing code to be used at lower level from Swift scripts:

char operation = 'n'; // n: normal; m: do one multi_loss (with n_reruns).
                      // Not used: a: analyze and generate next annealing parameter set. g: tbd

unsigned initSeed = 0;

/*
 * Gemtc Id counter
 */
int update_id = 0;

#include <fstream>
#include <iostream>
#include <stdio.h>
#include <time.h>
#include <ctime>
#include <algorithm>
#include <string>
#include <vector>
#include <iterator>

#include <stdio.h>
#include <sys/param.h>
#include <sys/time.h>
#include <sys/types.h>

#ifdef P_DISPATCH
#include <dispatch/dispatch.h>
#else
// Define dummy types to allow same method signatures
typedef int dispatch_group_t;
typedef void dispatch_queue_t;

#define NO_DISPATCH_GROUP 0
#define NO_DISPATCH_QS NULL
#endif

#include <fstream>


#include <stdlib.h>
#include <boost/numeric/ublas/io.hpp>
#include <boost/graph/graph_traits.hpp>
#include <boost/graph/dijkstra_shortest_paths.hpp>
#include <boost/property_map/property_map.hpp>
#include <boost/graph/graph_concepts.hpp>
#include <boost/graph/properties.hpp>

#include <boost/graph/graph_traits.hpp>
#include <boost/graph/adjacency_matrix.hpp>

#define BOOST_MATH_OVERFLOW_ERROR_POLICY ignore_error
#define BOOST_MATH_DISCRETE_QUANTILE_POLICY real
#include <boost/graph/random.hpp>
#include <boost/random/geometric_distribution.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/random.hpp>
#include <boost/random/linear_congruential.hpp>
#include <boost/random/uniform_int.hpp>
#include <boost/random/uniform_real.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/generator_iterator.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/math/special_functions/fpclassify.hpp>
#include <cfloat>
#include "timers.h"

#define INT_INFINITY 2147483647

#define FIX_VARIABLES 0

/*
 * GPU extern
*/

extern "C" void gemtcSetup(int QueueSize, int Overfill);
extern "C" void gemtcPoll(int *ID, void **params);
extern "C" void gemtcMemcpyHostToDevice(void *device, void *host, int size);
extern "C" void *gemtcGPUMalloc(int size);
extern "C" void gemtcPush(int taskType, int threads, int ID, void *d_parameters);
extern "C" void gemtcGPUFree(void *p);
extern "C" void gemtcMemcpyDeviceToHost(void *host, void *device, int size);

static int largest_current_repeat = 0;

using namespace boost;
using namespace std;
using namespace boost::numeric::ublas;

//static int max_dist=0;

typedef boost::adjacency_matrix<boost::directedS> Graph;
typedef std::pair<int,int> Edge;
typedef boost::graph_traits<Graph> GraphTraits;
typedef boost::numeric::ublas::triangular_matrix<double, boost::numeric::ublas::strict_upper> prob;
typedef boost::numeric::ublas::triangular_matrix<double, boost::numeric::ublas::strict_upper> pathlength;
typedef boost::graph_traits<Graph>::vertex_descriptor vertex_descriptor;

namespace std {
  using ::time;
}

static int var_fixed[5] = {0, 0, 0, 0, 0};
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

typedef boost::minstd_rand base_generator_type;
typedef adjacency_list < listS, vecS, directedS,
no_property, property < edge_weight_t, int > > graph_t;
typedef graph_traits < graph_t >::vertex_descriptor vertex_descriptor;
typedef graph_traits < graph_t >::edge_descriptor edge_descriptor;

// Cache the last loaded graph file to avoid filesystem reads
// TODO: this will not work with multi-threaded code!
static bool have_cached_graph = false;
static std::string cached_graph_file;
static int cached_graph_nodes;
static std::vector<pair<int, int> > cached_graph_edges;

// Macros for optional profilng
#ifndef DO_PROFILE
#define DO_PROFILE 0
#endif

#if DO_PROFILE
#define TIMER_DECLARE(name) struct timeval __start_##name, __end_##name
#define TIMER_START(name) gettimeofday(&__start_##name, NULL)
#define TIMER_END(name) gettimeofday(&__end_##name, NULL)
#define GET_TIMING(name) timediff_s(__start_##name, __end_##name)
#define PRINT_TIMING(name, msg) printf("%s: %.3f\n", msg, \
                                GET_TIMING(name))
#else
#define TIMER_DECLARE(name)
#define TIMER_START(name)
#define TIMER_END(name)
#define GET_TIMING(name)
#define PRINT_TIMING(name, msg)
#endif


// Type used to represent state of edge (final and tried)
// Use bitfield so compact in memory
/*typedef struct {
    bool final : 1;
    bool tried : 1;
} edge_state;
*/
typedef struct {
    int final;
    int tried;
} edge_state;

//================================================
string strDouble(double number)
{
  stringstream ss;//create a stringstream
  ss << number;//add number to the stream
  return ss.str();//return a string with the contents of the stream
}

//================================================

double gaussian(double sigma)
{
  double GaussNum = 0.0;
  int NumInSum = 10;
  for(int i = 0; i < NumInSum; i++)
  {
    GaussNum += ((double)rand()/(double)RAND_MAX - 0.5);
  }
  GaussNum = GaussNum*sqrt((double)12/(double)NumInSum);


  return GaussNum;

}



//=================================================
double diffclock(clock_t clock1,clock_t clock2)
{
  double diffticks=clock1-clock2;
  double diffms=(diffticks)/CLOCKS_PER_SEC;
  return diffms;
}

//================================================
//================================================================
double get_new_x(double x, double dx){

  double new_x;
  // boost::variate_generator<base_generator_type&, boost::uniform_real<> > uni(generator, uni_dist);
  double r = rand()/(double)(pow(2.,31)-1.);

  if (r > 0.5){
    new_x = x + rand()*dx/(double)(pow(2.,31)-1.);
  } else {
    new_x = x - rand()*dx/(double)(pow(2.,31)-1.);
  }

  return new_x;

}


//===============================================
string string_wrap(string ins, int mode){

  std::ostringstream s;

  switch(mode){
    case 0:
      s << "\033[1;29m" << ins << "\033[0m";
      break;
    case 1:
      s << "\033[1;34m" << ins << "\033[0m";
      break;
    case 2:
      s << "\033[1;44m" << ins << "\033[0m";
      break;
    case 3:
      s << "\033[1;35m" << ins << "\033[0m";
      break;
    case 4:
      s << "\033[1;33;44m" << ins << "\033[0m";
      break;
    case 5:
      s << "\033[1;47;34m" << ins << "\033[0m";
      break;
    case 6:
      s << "\033[1;1;31m" << ins << "\033[0m";
      break;
    case 7:
      s << "\033[1;1;33m" << ins << "\033[0m";
      break;
    case 8:
      s << "\033[1;1;43;34m" << ins << "\033[0m";
      break;
    case 9:
      s << "\033[1;1;37m" << ins << "\033[0m";
      break;
    case 10:
      s << "\033[1;30;47m" << ins << "\033[0m";
      break;
    default:
      s << ins;
  }

  return s.str();
}


//===============================================
string wrap_double(double val, int mode){

  std::ostringstream s;
  s << string_wrap(strDouble(val),mode);

  return s.str();
}

//===============================================
const
string i2string(int i){

  std::ostringstream s;
  s << "worker"
    << lexical_cast<std::string>(i);

  return s.str();

}

//===============================================
char* i2char(int i){

  std::ostringstream s;
  s << "worker"
    << lexical_cast<std::string>(i);

  char* a=new char[s.str().size()+1];
  memcpy(a,s.str().c_str(), s.str().size());

  return a;
}

//================================================
class Universe {

private:

  double alpha_i;
  double alpha_m;
  double beta;
  double gamma;
  double delta;

  double TargetNovelty;
  double CumulativeRelativeLoss;
  double CRLsquare;
  string id;


  int N_nodes;
  int M_edges;

  int N_epochs;
  int N_steps;
  int N_repeats;

  int current_epoch;
  double current_loss;
  int current_repeat;
  double current_novelty;

  int mode_identify_failed;
  int verbose_level; // 0 is silent, higher is more

  double k_max;

  graph_t Full_g;
  
  edge_state **State;
  /* Track number of tries */
  int **Tried;
  /* Count of tried edges */
  int num_tried;
  /* Sum of untried probabilities per row */
  double *ProbSums;
  /* Total sum of probs */
  double TotalProb;
  double **Prob;
  double **Dist;
  double **EdgeIndex;
  double *Rank;

  base_generator_type generator;
  boost::uniform_real<> uni_dist;
  boost::geometric_distribution<double> geo;


  void mark_edge_tried(int i, int j) {
    if (!State[i][j].tried) {
      State[i][j].tried = true;
      num_tried++;
      // Update row sums so not to include tried
      ProbSums[i] -= Prob[i][j];
      TotalProb -= Prob[i][j];
    }
  }
public:



  //======  Constructor ======
  Universe(const std::string FileToOpen, int Epochs, int Steps, int Repeats, int identify_failed, double target, const std::string idd)
  {
    //typedef array_type2::index index2;


    //string line;

    //-------------------------------

    base_generator_type gene(42u);
    generator = gene;
    generator.seed(static_cast<unsigned int>(std::time(0)));
    boost::uniform_real<> uni_d(0,1);
    uni_dist = uni_d;

    //--------------------------------

    TargetNovelty = target;
    CumulativeRelativeLoss = 0.;
    CRLsquare = 0.;


    N_epochs  = Epochs;
    N_steps   = Steps;
    N_repeats = Repeats;

    current_epoch = 0;
    current_loss = 0.;
    current_repeat = 0;

    id = idd;

    verbose_level = 1;

    mode_identify_failed = identify_failed;
    load_graph(FileToOpen);
  }

  void load_graph(const std::string &filename) {
    const std::vector<pair<int, int> > *edges;
    int nodes, edge_count;
    if (have_cached_graph && cached_graph_file == filename) {
      edges = &cached_graph_edges;
      nodes = cached_graph_nodes;
    } else {
      // Load data from file into vector
      ifstream inFile;
      inFile.open(filename.c_str());
      if (inFile.fail()) {
        cout << "Unable to open file: " << filename << endl;
        exit(1); // terminate with error
      }else {

        if (verbose_level > 2){
          std::cout <<  " Opened <" << filename << ">" << std::endl;
        }
      }

      inFile >> nodes;
      inFile >> edge_count;

      if (verbose_level > 2){
        std::cout << " N_nodes: " << nodes;
        std::cout << " M_edges: " << edge_count << std::endl;
      }
      
      cached_graph_edges.clear();
      cached_graph_edges.reserve(edge_count);
      
      int x, y;
      while (inFile >> x && inFile >> y) {
        if (x >= 0 && y >= 0 && y < nodes && x < nodes) {
          cached_graph_edges.push_back(pair<int, int>(x, y));
        } else {
          cout << "Warning, edge (" << x << ", " << y << ") "
               << "out of range, skipping.";
        }
      }
      if (!inFile.eof()) {
        cout << "Warning: loaded " << cached_graph_edges.size() 
             << "edges but did not reach EOF";
      }
      inFile.close();

      if (cached_graph_edges.size() != edge_count) {
        cout << "Warning: file header claimed " << edge_count
             << "edges but only loaded " << cached_graph_edges.size();
      }

      have_cached_graph = true;
      cached_graph_file = filename;
      cached_graph_nodes = nodes;
      edges = &cached_graph_edges;
    }
    // Now, build graph from vector
    init_graph(nodes, *edges);
  }

  // Initialize graph data structures from edge list
  void init_graph(int nodes, const std::vector<pair<int, int> > &edges) {
    N_nodes = nodes;
    M_edges = edges.size();
    if (verbose_level == 2){
      std::cout << N_nodes <<  " nodes, " << M_edges << " edges"<<std::endl;
    }

    // k_max is the longest distance possible

    //k_max = M_edges;
    k_max = 70;

    //------------------------------------
    // Get memory allocated for all class members

    ProbSums = allocate_1Dmatrix(N_nodes);
    Prob = allocate_2Dmatrix(N_nodes, N_nodes);
    Dist = allocate_2Dmatrix(N_nodes, N_nodes);
    if (ALL_VISIBLE == 0) {
        Tried = allocate_2Dmatrix_t<int>(N_nodes, N_nodes);
    } else {
        Tried = NULL;
    }

    State = allocate_2Dmatrix_t<edge_state>(N_nodes, N_nodes);
    EdgeIndex = allocate_2Dmatrix(N_nodes, N_nodes);
    Rank = allocate_1Dmatrix(N_nodes);

    //The second pass through file with the graph
    num_tried = 0;
    TotalProb = 0.;
    for(int i = 0; i < N_nodes; ++i) {
      Rank[i]=0.;
      ProbSums[i]=0.;
      for(int j = 0; j < N_nodes; ++j) {
        State[i][j].tried = false;
        State[i][j].final = false;
        if (Tried != NULL)
            Tried[i][j] = 0;
        Prob[i][j]=0.;
        Dist[i][j]=-1.;
        EdgeIndex[i][j]=-1;
      }
    }


    // Fill in the final graph -- and we are ready to go!
    std::vector<std::pair<int, int> >::const_iterator it;
    for (it = edges.begin(); it != edges.end(); ++it) {
      int x = it->first;
      int y = it->second;
      State[x][y].final = true;
      State[y][x].final = true;

      if (verbose_level == 2){
        std::cout << ".";
      }
    }
    if (verbose_level == 2){
      std::cout << std::endl;
    }

    int k=0;
    for (int i=0; i<N_nodes-1; i++){
      for (int j=i+1;j<N_nodes; j++){
        if(State[i][j].final){
          EdgeIndex[i][j]=k;
          k++;
        }
      }
    }



    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // create graph -- hopefully, we can keep it, just modifying edge weights
    Edge* edge_array_mine;
    int num_arcs_mine, num_nodes_mine;
    int* weights_mine;

    edge_array_mine = new Edge[2*M_edges];
    num_arcs_mine = 2*M_edges;
    num_nodes_mine = N_nodes;
    weights_mine = new int[2*M_edges];
    for (int i=0; i<2*M_edges; i++){ weights_mine[i]=1;}

    k=0;
    for(int i=0; i<N_nodes-1; i++){
      for( int j=i+1; j<N_nodes; j++){
        if (State[i][j].final){
          edge_array_mine[2*k]  =Edge(i,j);
          edge_array_mine[2*k+1]=Edge(j,i);
          k++;
        }
      }
    }
    graph_t g(edge_array_mine, edge_array_mine + num_arcs_mine, weights_mine, num_nodes_mine);

    Full_g = g;
    delete edge_array_mine;
    delete weights_mine;

    //===========================================================================
    std::vector<edge_descriptor> p(num_edges(Full_g));
    std::vector<int> d(num_edges(Full_g));
    edge_descriptor s;
    boost::graph_traits<graph_t>::vertex_descriptor u, v;

    for (int i=0; i<N_nodes-1; i++){
      for (int j=i+1; j<N_nodes; j++){
        if (State[i][j].final){
          u = vertex(i, Full_g);
          v = vertex(j, Full_g);
          remove_edge(u,v,Full_g);
          remove_edge(v,u,Full_g);

        }
      }
    }
    
  }

  void set_verbose_level(int level) {
    verbose_level = level;
  }


  //=====================================================================
  int sample_failed_number(double pfail){

    //boost::geometric_distribution<double> geo(pfail);
    //boost::variate_generator<base_generator_type&, geometric_distribution<double> > geom(generator, geo);

    double r, u, g;

    r=0.;
    for(int i=0; i<N_steps; i++){

      u=(double)rand();
      u = 1.-u /(double)(pow(2.,31)-1.);
      g=(int)(ceil(log(u) / log(pfail)));

      //r += geom();

      r+=g;
    }

    if (verbose_level>=3){
      std::cout << id << " failed " << r << std::endl;
    }
    return (int) round(r);  // FIXME: Andrey: please verify that round() is correct.

  }

  //=============================================
  double get_target(void){
    return TargetNovelty;
  }

  //=============================================
  void set_target(double target){
    TargetNovelty=target;
  }

  //=============================================
  int sample(){

    //boost::variate_generator<base_generator_type&, boost::uniform_real<> > uni(generator, uni_dist);
    // double r = uni(), Summa = 0.;



    double r = rand(), Summa = 0.;
    r /= (double)(pow(2.,31)-1.);
    int result = 0;
    int finished = 0;

    if (verbose_level==4){
      std::cout << id << " sampled " << r << std::endl;
    }

    for(int i=0; i<N_nodes-1 && finished==0; i++){
      if (!boost::math::isfinite(ProbSums[i])) {
        printf("DEBUG: Invalid probsums[%i]: %.17g\n", i, ProbSums[i]);
        ProbSums[i] = 0.0;
      }
      if (Summa + ProbSums[i] <= r) {
        // Skip a row at a time
        Summa += ProbSums[i];
      } else {
        for( int j=i+1; j<N_nodes && finished==0; j++){

          Summa += Prob[i][j];

          if (Summa > r){
            mark_edge_tried(i, j);
            Tried[i][j]++;
            if (State[i][j].final){
              result = 1;
            }
            finished = 1;
          }
        }
      }
    }

    return result;

  }
	//=============================================
    std::pair<int,int> sample_all_visible(){
        
        double r, Summa = 0.;
        std::pair<int,int> result;
        result.first=0;
        result.second=0;        
        
        if (verbose_level==4){
            std::cout << id << " sampled " << r << std::endl;
        }

        if (num_tried == (N_nodes-1)*N_nodes/2){
            result.first=0;
            result.second=1;
            
            return result;
        }
        
        if (TotalProb <= 0.001) {
          // If probability has been reduced greatly, recompute all probabilities
          // This is to deal with probability precision drifting, and also
          // to handle infinite or very large probabilities that can occur
          // sometimes and mess up calculation precision.
          update_probabilities_all_visible();
        }

        r = rand();
        r /= (double)(pow(2.,31)-1.);
        r *= TotalProb; // TotalProb may be <=1
        
        for(int i=0; i<N_nodes-1; i++){
            if (Summa + ProbSums[i] <= r) {
                // Skip a row at a time
                Summa += ProbSums[i];
            } else {
                for( int j=i+1; j<N_nodes; j++){
                    if(!State[i][j].tried){
                        //*****************
                        Summa += Prob[i][j];
                        if (Summa > r) {
                            mark_edge_tried(i, j);
                            if (State[i][j].final){
                                result.first = 1;
                            }
                            return result; 
                        }
                        //*******************
                    }
                }
            }
        }
          
        // Prob out of range, recompute to be sure

        printf("DEBUG: Probability out of range.  "
               "r=%.17lg Summa=%.17lg TotalProb=%.17lg\n",
                r, Summa, TotalProb);
        update_probabilities_all_visible();
 
        return result;
    }

  //===============================
  void update_current_graph(void){

    std::vector<edge_descriptor> p(num_edges(Full_g));
    std::vector<int> d(num_edges(Full_g));
    edge_descriptor s;
    boost::graph_traits<graph_t>::vertex_descriptor u, v;

    //property_map<graph_t, edge_weight_t>::type weightmap = get(edge_weight, Full_g);
    for (int i=0; i<N_nodes-1; i++){
      for (int j=i+1; j<N_nodes; j++){
        if (State[i][j].tried && State[i][j].final){
          //s = edge(i, j, Full_g);
          boost::graph_traits<graph_t>::edge_descriptor e1,e2;
          bool found1, found2;
          u = vertex(i, Full_g);
          v = vertex(j, Full_g);
          tie(e1, found1) = edge(u, v, Full_g);
          tie(e2, found2) = edge(v, u, Full_g);
          if (!found1 && !found2){
            add_edge(u,v,1,Full_g);
            add_edge(v,u,1,Full_g);
          }

        }
      }

    }
  }

  //===============================
  void update_distances(void){
    // put shortest paths to the *Dist[][]
    std::vector<vertex_descriptor> p(num_vertices(Full_g));
    std::vector<int> d(num_vertices(Full_g));
    vertex_descriptor s;


    // put shortest paths to the *Dist[][]
    for (int j=0; ((unsigned int)j)<num_vertices(Full_g); j++){

      if(Rank[j] > 0.){
        s = vertex(j, Full_g);
        dijkstra_shortest_paths(Full_g, s, predecessor_map(&p[0]).distance_map(&d[0]));

        //std::cout <<" Vertex "<< j << std::endl;
        graph_traits < graph_t >::vertex_iterator vi, vend;

        for (boost::tie(vi, vend) = vertices(Full_g); vi != vend; ++vi) {

          if (p[*vi]!=*vi){
            Dist[*vi][j]=d[*vi];
            Dist[j][*vi]=d[*vi];

            //if ( (int)round(Dist[*vi][j]>max_dist)) {
              // FIXME: Andrey: please verify that (int) cast is correct. Do we need to round()?
              // also, the indent on this iff statement was way off -
              // perhaps due to space v. tab?
              //max_dist=(int)round(Dist[*vi][j]);
            //}


          } else {
            Dist[*vi][j]=-1.;
            Dist[j][*vi]=-1.;
          }
        }
      }

    }


  }

  //======================================================
  void update_ranks(void){

    for(int i=0; i<N_nodes; i++){
      Rank[i]=0.;
    }

    for(int i=0; i<N_nodes-1; i++){
      for( int j=i+1; j<N_nodes; j++){
        if (State[i][j].tried && State[i][j].final){
          Rank[i]++;
          Rank[j]++;
        }
      }
    }

  }

  //====================================================================
  void set_world(double a_i, double a_m, double b, double g, double d){

    alpha_i=a_i;
    alpha_m=a_m;
    gamma=g;
    beta=b;
    delta=d;

   largest_current_repeat = 0;

  }

  //====================================================================
  void reset_world(){


        if(verbose_level==4){
        cout << string_wrap(id,6) << " resetting \n\n";
		}
        
    //====================================================
    std::vector<edge_descriptor> p(num_edges(Full_g));
    std::vector<int> d(num_edges(Full_g));
    edge_descriptor s;
    boost::graph_traits<graph_t>::vertex_descriptor u, v;


    for (int i=0; i<N_nodes-1; i++){
      for (int j=i+1; j<N_nodes; j++){
        if (State[i][j].tried && State[i][j].final){
          u = vertex(i, Full_g);
          v = vertex(j, Full_g);
          remove_edge(u,v,Full_g);
          remove_edge(v,u,Full_g);

        }
      }
    }

    //==================================================

    current_loss=0;
    current_epoch=0;
    current_repeat++;
    current_novelty=0;
    
    num_tried = 0;
    TotalProb = 0.;
    for(int i = 0; i < N_nodes; ++i) {
      Rank[i]=0.;
      ProbSums[i] = 0.;
      for(int j = 0; j < N_nodes; ++j) {
        Prob[i][j]=0.;
        Dist[i][j]=-1.;
        State[i][j].tried=false;
        if (Tried != NULL)
            Tried[i][j] = 0;
      }
    }
  }


  //==============================================
  void show_parameters(void){

    std::cout << "Parameters: "
              << alpha_i << " "
              << alpha_m << " | "
              << beta << " "
              << gamma << " | "
              << delta << std::endl;

  }



  //===============================================
  string file_name(){

    std::ostringstream s;

    if(ALL_VISIBLE == 0){
        s << "world_"
          << lexical_cast<std::string>(alpha_i) << "_"
          << lexical_cast<std::string>(alpha_m) << "_"
          << lexical_cast<std::string>(beta) << "_"
          << lexical_cast<std::string>(gamma) << "_"
          << lexical_cast<std::string>(delta) << "_"
          << lexical_cast<std::string>(N_epochs) << "_"
          << lexical_cast<std::string>(N_steps) << "_"
          << lexical_cast<std::string>(N_repeats) << ".txt";
    } else{
        s << "world_"
          << lexical_cast<std::string>(alpha_i) << "_"
          << lexical_cast<std::string>(alpha_m) << "_"
          << lexical_cast<std::string>(beta) << "_"
          << lexical_cast<std::string>(gamma) << "_"
          << lexical_cast<std::string>(delta) << "_"
          << lexical_cast<std::string>(N_epochs) << "_"
          << lexical_cast<std::string>(N_steps) << "_"
          << lexical_cast<std::string>(N_repeats) << "_all_visible.txt";
            
    }
    return s.str();

  }




  //=================================================
  void set_verbose(int verbose){

    verbose_level = verbose;
  }


  //=============================================================
  void update_probabilities(void){


    //=========================
    // Compute sampling probabilities
    // first pass: \xi_i,j
    for(int i=0; i<N_nodes-1; i++){
      double probSum = 0.0;
      for( int j=i+1; j<N_nodes; j++){

        double bg = 0.;
        Prob[i][j] = alpha_i*log(min(Rank[i]+1.,Rank[j]+1.)) +
          alpha_m*log(max(Rank[i]+1.,Rank[j]+1.));

        if (Dist[i][j] > 0.){

          double k = Dist[i][j];
          if (k >= k_max){
            k = k_max-1;
          }

          bg = beta * log(k/k_max) + gamma * log(1. - k/k_max);

        } else {
          bg = delta;
        }

        Prob[i][j] = exp(Prob[i][j] + bg);
        probSum += Prob[i][j];
      }
      ProbSums[i] = probSum;
    }


    // second pass: sum
    double Summa = 0.;
    for(int i=0; i<N_nodes-1; i++){
      Summa += ProbSums[i];
    }

    // third pass: normalize
    TotalProb = 1.; // Total 1 since normalized
    for(int i=0; i<N_nodes-1; i++){
      for( int j=i+1; j<N_nodes; j++){
        Prob[i][j] /= Summa;
      }
      ProbSums[i] /= Summa;
    }

  }

    
    //=============================================================
    void update_probabilities_all_visible(void){
        static int m = 0;
        m++;
        printf(" SEQUENCE %d\n", m);
        double num_of_nodes = N_nodes;
        double func_id = 1.;
        //=========================
        // Pre-compute logs
        double *LogRanks = new double[N_nodes];

        /*
         * N_nodes, alpha_i, alpha_m, k_max, beta, gamma, delta, TotalProb,
         * LogRanks, Rank, State, Probsums, Prob, Dist
         */
        int mem_needed = 9*sizeof(double) + 3*N_nodes*sizeof(double) +
                         N_nodes*N_nodes*sizeof(edge_state) + 
                         2*N_nodes*N_nodes*sizeof(double); 
        printf("Allocation %d bytes\n", mem_needed);
        /*
         * Allocate memory for GPU invocation
         */
        double* d_memory = (double*)gemtcGPUMalloc(mem_needed);
        if(d_memory == NULL) {
            printf("CPU: Unable to allocate memory\n");
            return;
        }
        printf("N_nodes %d edge_state %d \n", N_nodes, sizeof(edge_state));
         
        printf(" CPU::Alpha_i %f\n", alpha_i);
        printf(" CPU::Alpha_m %f\n", alpha_m);
        printf(" CPU::k_max %f\n", k_max);
        printf(" CPU::beta %f\n", beta);
        printf(" CPU::gamma %f\n", gamma);
        printf(" CPU::delta %f\n", delta);
        printf(" CPU::Total probability %f\n", TotalProb);
        printf(" CPU::sizeof double %d sizeof int %d\n", sizeof(double), sizeof(int));

/*
        printf("CPU:: Printing State\n");
        for(int i=0; i<5;i++) {
            for(int j=0;j<5;j++) {
                printf("    State[%d][%d].final = %d:: State[%d][%d].tried = %d", i, j, State[i][j].final, i, j, State[i][j].tried);
            }
            printf("\n");
        }*/
    //for(int i = 0; i <N_nodes; i++) {
        //for(int j=0; j<N_nodes; j++) {
            //printf(" State[%d][%d]=%x\n", i, j, State[i][j]);
        //}
        //printf("\n\n\n");
    //}

        /*
         * Copy data to device
         */
        gemtcMemcpyHostToDevice((double*)d_memory, &func_id, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 1, &num_of_nodes, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 2, &alpha_i, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 3, &alpha_m, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 4, &k_max, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 5, &beta, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 6, &gamma, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 7, &delta, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 8, &TotalProb, sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 9, LogRanks, N_nodes*sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 9 + N_nodes, Rank, N_nodes*sizeof(double));
        gemtcMemcpyHostToDevice((double*)d_memory + 9 + 2*N_nodes, ProbSums, N_nodes*sizeof(double));

        printf("STARTING LONG PROCESS\n");
        for(int i=0; i <N_nodes;i++) {
            gemtcMemcpyHostToDevice(((double*)d_memory) + 9 + 3*N_nodes + N_nodes*i, Prob[i], N_nodes*sizeof(double));
        }
        printf("Prob copied\n");

        for(int i=0; i <N_nodes;i++) {
            gemtcMemcpyHostToDevice(((double*)d_memory) + 9 + 3*N_nodes + N_nodes*N_nodes + N_nodes*i, Dist[i], N_nodes*sizeof(double));
        }
        printf("Dist copied\n");
        //gemtcMemcpyHostToDevice((edge_state*)d_memory + (9 + 3*N_nodes + 2*N_nodes*N_nodes)*sizeof(double), State, N_nodes*N_nodes*sizeof(edge_state));
        for(int i=0; i <N_nodes;i++) {
            gemtcMemcpyHostToDevice(((edge_state*)d_memory) + (9 + 3*N_nodes + 2*N_nodes*N_nodes + N_nodes*i), State[i], N_nodes*sizeof(edge_state));
        }
        printf("State copied\n");
        
        pthread_mutex_lock(&mutex);
        update_id++;
        pthread_mutex_unlock(&mutex);
        gemtcPush(26, 32, update_id, d_memory);
        printf("BACK IN CPU\n");
        void *ret=NULL;
        int id;
        while(ret==NULL){
            //printf("HITTING IN WHILE\n");
            gemtcPoll(&id, &ret);
        }
        printf("CPU: DEBUG 6\n");

        gemtcMemcpyDeviceToHost(ProbSums, (double*)ret + 9 + 2*N_nodes, N_nodes*sizeof(double));
        for(int i=0; i <N_nodes;i++) {
            gemtcMemcpyDeviceToHost(Prob[i], (double*)ret + 9 + 3*N_nodes + i*N_nodes, N_nodes*sizeof(double));
        }
        gemtcGPUFree(ret);
        printf("CPU: DEBUG 7\n");
        delete [] LogRanks;
        TotalProb = 1.0;
        printf("CPU: DEBUG 8\n");
        printf(" SEQUENCE %d\n", m);
    }

    
  // Now we are ready for simulations
  //==============================================
  void update_world(){

    int failed = 0;

    // Given current universe compute shortest paths
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    update_current_graph();
    update_ranks();
    update_distances();
    update_probabilities();

    //===============================
    // sampling
    int result;
    double cost=0., novel=0.;
    int publishable = 0;


    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    if (mode_identify_failed == 1){

      while(publishable < N_steps){

        result = sample();
        publishable += result;
        failed += (1-result);

      }

      for(int i=0; i<N_nodes-1; i++){
        for( int j=i+1; j<N_nodes; j++){
          cost += Tried[i][j];

          if (State[i][j].tried && State[i][j].final){
            novel+=1.;
          }
        }
      }

    }
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    else {

      double pfail=0.;
      int n_failed;
      //, n_check = 0;

      for(int i=0; i<N_nodes-1; i++){
        for( int j=i+1; j<N_nodes; j++){
          if (!State[i][j].final){
            pfail += Prob[i][j];
            if (!State[i][j].tried) {
              ProbSums[i] -= Prob[i][j];
            }
            Prob[i][j] = 0.;
          }

        }
      }

      for(int i=0; i<N_nodes-1; i++){
        for( int j=i+1; j<N_nodes; j++){
          Prob[i][j] /= (1.-pfail);
        }
        ProbSums[i] /= (1.-pfail);
        //std::cout << std::endl;
      }

      n_failed = sample_failed_number(pfail);
      while(publishable < N_steps){

        result = sample();
        publishable += result;
      }


      current_loss += (n_failed + N_steps);
      cost = current_loss;

      for(int i=0; i<N_nodes-1; i++){
        for( int j=i+1; j<N_nodes; j++){

          if (State[i][j].tried && State[i][j].final){
            novel+=1.;
          }
        }
      }
    }

    current_novelty = novel;

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    if (verbose_level == 2){
      std::cout << (current_repeat+1) << "  epoch=" << (current_epoch+1)

                << "  cost=" << cost
                << " novel=" << novel
                << " rel_loss=" << cost/novel
                << std::endl;
    }

    current_epoch++;
  }

    //==============================================
    int update_world_all_visible(){
        
        DBG_TIMER_DECLARE(t);
        int failed = 0;
        
        // Given current universe compute shortest paths
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        DBG_TIMER_START(t);
        update_current_graph();
        DBG_TIMER_END(t);
        DBG_PRINT_TIMING(t, "update_current_graph()");
        
        DBG_TIMER_START(t);
        update_ranks();
        DBG_TIMER_END(t);
        DBG_PRINT_TIMING(t, "update_ranks()");
        DBG_TIMER_START(t);
        update_distances();
        DBG_TIMER_END(t);
        DBG_PRINT_TIMING(t, "update_distances()");
        DBG_TIMER_START(t);
        update_probabilities_all_visible();
        DBG_TIMER_END(t);
        DBG_PRINT_TIMING(t, "update_probabilities_all_visible()");
        
        //===============================
        // sampling
        std::pair<int,int> result;
        result.first=0;
        result.second=0;
        
        double cost=0., novel=0.;
        int publishable = 0;        
        
        //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
        DBG_TIMER_START(t);
        /* N_steps is the maximum number of real edges to find in an epoch.
         * TargetNovelty is the maximum number to find overall across all
         * epochs */
        double remaining_novelty = TargetNovelty - current_novelty;
        int epoch_steps = min(N_steps, (int)remaining_novelty);
        int sample_calls = 0;
        while(publishable < epoch_steps && result.second == 0) {
            result = sample_all_visible();
            publishable += result.first;
            failed += (1-result.first);
            sample_calls++;
            if (verbose_level > 3 && sample_calls % 1000 == 0) {
              printf("publishable: %i/%i, samples: %i\n", publishable, epoch_steps,
                                                        sample_calls);
            }
        }
        DBG_TIMER_END(t);
        DBG_PRINT_TIMING(t, "sample_all_visible() loop");
 #if DO_PROFILE > PROFILE_DBG
        printf("sample_all_visible() calls: %i fail: %i\n", sample_calls,
                                                            result.second);
 #endif
        
        for(int i=0; i<N_nodes-1; i++){
            for( int j=i+1; j<N_nodes; j++){
               
                if (State[i][j].tried) {
                    cost+=1;
                }
                if (State[i][j].tried && State[i][j].final){
                    novel+=1.;
                }
            }
        }
        
        current_novelty = novel;
        current_loss = cost;
               

        //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        if (verbose_level == 1){
            if(novel >= TargetNovelty)
                  std::cout << "." ;
        }
        if (verbose_level == 2){
            
            if (novel < TargetNovelty){
            }
            else {
            std::cout << string_wrap(id,1) << " " << (current_repeat+1) << "  epoch=" << (current_epoch+1)
            << " all_visible_cost=" << cost
            << " novel=" << wrap_double((double)novel,6)
            << " rel_loss=" << cost/novel
            << std::endl;
            }
        }
        
        current_epoch++;
        
        return result.second;
    }


  //======  Destructor ======
  ~Universe(){

    delete_2Dmatrix(State, N_nodes);
    if (Tried != NULL)
        delete_2Dmatrix(Tried, N_nodes);
    delete_2Dmatrix(Dist, N_nodes);
    delete_2Dmatrix(Prob, N_nodes);
    delete_1Dmatrix(ProbSums);
    delete_2Dmatrix(EdgeIndex, N_nodes);
    delete_1Dmatrix(Rank);
  }

  //================================================
  // Allocate memory
  double** allocate_2Dmatrix(int N, int M)
  {
    return allocate_2Dmatrix_t<double>(N, M);
  }
  //================================================
  // Allocate memory for generic array
  template <class T>
  T** allocate_2Dmatrix_t(int N, int M)
  {
    T **pointer;

    if (verbose_level == 2){
      std::cout<< "["<<N<<"|"<<M<<"]"<<std::endl;
    }
    pointer = new T*[N];
    for (int i = 0; i < N; ++i)
      pointer[i] = new T[M];

    return pointer;
  }
  //===================
  double* allocate_1Dmatrix(int N)
  {
    double *pointer;

    if(N > 0){

      pointer = new double[N];

    }else {

      pointer = NULL;
    }

    return pointer;

  }

  //==============================================
  // De-Allocate memory to prevent memory leak
  template <class T>
  void delete_2Dmatrix(T **pointer, int N){

    if (pointer != NULL){

      for (int i = 0; i < N; ++i){
        delete [] pointer[i];
      }
      delete [] pointer;
    }
  }

  //====================
  void delete_1Dmatrix(double *pointer){

    delete [] pointer;
  }

  //===========================================
  double get_rel_loss(){

    return CumulativeRelativeLoss ;
  }

  //===========================================
  double get_rel_loss_err(){

    return CRLsquare ;
  }


  //==================================================================================
  void evolve_to_target_and_save(int istart, int iend, double* storage, int* counters){

    reset_world();
    
    pthread_mutex_lock(&mutex);

    if (verbose_level > 1){
        cout << string_wrap(id,3) << " from " << istart << " to " << iend << "\n";  
    }

    pthread_mutex_unlock(&mutex);
    
    int res=0;
    current_repeat=0;
    for (int k = istart; k < iend; k++){

      for(int i=0; i< N_epochs &&  current_novelty < TargetNovelty; i++){
          DBG_TIMER_DECLARE(t);
          DBG_TIMER_START(t);
          if(ALL_VISIBLE==0) update_world();
          else { res = update_world_all_visible(); }
          if (res == 1) break;
          DBG_TIMER_END(t);
          DBG_PRINT_TIMING(t, "update_world()");
          if (verbose_level >= 3) {
            printf("After epoch %i/%i: novelty %li/%li tested %i/%i\n",
                i + 1, N_epochs, (long)current_novelty, (long)TargetNovelty,
                num_tried, (N_nodes-1)*N_nodes/2);
          }
      }


      storage[k]=current_loss/current_novelty;
      counters[k]=1;

      reset_world();
    }

    if(verbose_level == 2){
        std::cout << wrap_double(current_loss/current_novelty,5) << std::endl;
    }

  }

  //==============================================
  int get_reruns(void){
    return N_repeats;
  }

  //==============================================
  double get_parameter(int i){

    switch(i){
      case 0:
        return alpha_i;
      case 1:
        return alpha_m;
      case 2:
        return beta;
      case 3:
        return gamma;
      case 4:
        return delta;
      default:

        std::cout << "Erroneous parameter id!!!!\n\n\n";
        return 0.;
    }
  }


  //==============================================
  void evolve_to_target(){

    reset_world();

    for (int k=0; k< N_repeats; k++){


      for(int i=0; i<N_epochs &&  current_novelty <= TargetNovelty; i++){
        update_world();
      }

      CumulativeRelativeLoss += current_loss/current_novelty;
      CRLsquare += (current_loss/current_novelty)*(current_loss/current_novelty);
      if(verbose_level==3){
        std::cout <<  CumulativeRelativeLoss << " | " << CRLsquare << std::endl;
      }

      if(verbose_level==1){
        std::cout <<  "." ;

      }
      else if(verbose_level==2){
        std::cout <<  "**" << (k+1) <<  "**  curr loss " << current_loss << "; curr novelty " << current_novelty << std::endl;
      }


      reset_world();
    }

    CumulativeRelativeLoss /= double(N_repeats);
    CRLsquare /= double(N_repeats);

    if(verbose_level==1){
      std::cout << std::endl;
    }

    if(verbose_level==2){
      std::cout <<  CumulativeRelativeLoss << " || " << CRLsquare << std::endl;
    }

    CRLsquare = 2*sqrt((CRLsquare - CumulativeRelativeLoss*CumulativeRelativeLoss)/double(N_repeats));

  }


  //================================================================
  int set_parameter(double value, int position){

    if (position < 0 || position > 4) {return 0;}

    else {

      switch(position){
        case 0:
          alpha_i=value;
          return 1;
        case 1:
          alpha_m=value;
          return 1;
        case 2:
          beta=value;
          return 1;
        case 3:
          gamma=value;
          return 1;
        case 4:
          delta=value;
          return 1;
      }

    }

    return 0;
  }


  //=================================================================
  void try_annealing(double starting_jump, int iterations,
                     double temp_start, double temp_end, double target_rejection){

    double dx[5]={0.,0.,0.,0.,0};
    double x[5]={0.,0.,0.,0.,0};
    double rejection[5]={0., 0., 0., 0., 0.};
    double curr_x, curr_err, x_tmp;
    double temperature;
    double ratio, r;
    int cycle=10;
    boost::variate_generator<base_generator_type&, boost::uniform_real<> > uni(generator, uni_dist);

    // set up parameter for annealing

    x[0]=alpha_i;
    x[1]=alpha_m;
    x[2]=beta;
    x[3]=gamma;
    x[4]=delta;

    for(int i=0;i<5;i++){
      dx[i] = starting_jump;
    }

    // establish the current value

    //..........................................
    evolve_to_target();
    std::cout << CumulativeRelativeLoss << " +- " << CRLsquare << std::endl;

    curr_x   = CumulativeRelativeLoss;
    curr_err = CRLsquare;
    CumulativeRelativeLoss = 0;
    CRLsquare = 0;
    //...........................................

    // optimization cycle
    for(int i=0; i<iterations; i++){

      temperature = temp_start*exp( i*(log(temp_end)-log(temp_start))/(double)iterations);
      std::cout  << std::endl << "....T = " << wrap_double(temperature,3) << std::endl << std::endl;

      if (i % cycle == 0 && i > 0){

        for (int k=0; k<5; k++){

          rejection[k]/=(double)cycle;
          if (rejection[k] > 0){
            dx[k] = dx[k]/(rejection[k]/target_rejection);
            rejection[k]=0.;
          }
          else{
            dx[k]*=2.;
          }
          std::cout  << dx[k] << " ";
        }
        std::cout  << std::endl;
      }


      for (int j=0; j<5; j++){

        // get new value of x[j]
        x_tmp = get_new_x(x[j],dx[j]);



        //.............................................
        set_parameter(x_tmp, j);


        evolve_to_target();

        std::cout  << std::endl << "......... " << std::endl;
        std::cout << "Trying... " << CumulativeRelativeLoss << " +- " << CRLsquare << std::endl;

        ratio = min(1.,exp(-(CumulativeRelativeLoss-curr_x)/temperature));
        r = uni();
        std::cout << r << " vs " << ratio << std::endl;

        if (r > ratio){

          std::cout << string_wrap(id, 4) <<" "<< (i+1) << ","<< (j)
                    <<" "<< (i+1) << " Did not accept "
                    << x_tmp << "(" << j << ")" << std::endl;
          std::cout << alpha_i << " "<< alpha_m << " "
                    << beta << " " << gamma << " "
                    << delta << " " << std::endl;
          set_parameter(x[j], j);
          CumulativeRelativeLoss = 0;
          CRLsquare = 0;

          rejection[j]+=1.;
        }

        else {

          curr_x   = CumulativeRelativeLoss;
          curr_err = CRLsquare;
          x[j] = x_tmp;
          CumulativeRelativeLoss = 0;
          CRLsquare = 0;
          std::cout << (i+1) << string_wrap((string) " Rejection counts: ", 8)
                    << wrap_double(rejection[0],6)
                    << " "<< wrap_double(rejection[1], 7) << " "
                    << wrap_double(rejection[2],5) << " " << wrap_double(rejection[2],9) << " "
                    << wrap_double(rejection[4],6) << " "
                    << std::endl << std::endl;

          std::cout << string_wrap(id, 4) <<" "<< (i+1) <<","<< (j)
                    <<" "
                    << string_wrap((string) "***** Did accept! ", 3)
                    << wrap_double(alpha_i,2)
                    << " "<< wrap_double(alpha_m, 7) << " "
                    << wrap_double(beta,5) << " "
                    << wrap_double(gamma,9) << " "
                    << wrap_double(delta,6) << " "
                    << std::endl << std::endl;

        }
        //........................................................

      }

    }

  }
};

//============================================================

std::pair<double,double> multi_loss(dispatch_group_t group,
                                    Universe* un[],
                                    dispatch_queue_t* CustomQueues,
                                    double* Results,
                                    int*    Counters,
                                    double* params){

    int N = un[0]->get_reruns();
    int step = (int)(double)N/(double)(Nworkers);

    double Loss=0., LossSquare=0.;

    //timeval startTime, endTime;
    //double elapsedTime;
    //gettimeofday(&startTime, NULL);

    for(int i=0; i<Nworkers; i++){
      for(int j=0; j<5; j++){
        un[i]->set_parameter(params[j],j);
      }
    }

#ifdef P_DISPATCH
    for(int i=0; i<Nworkers; i++){
      dispatch_group_async(group, CustomQueues[i], ^{
          un[i]->evolve_to_target_and_save(i*step, min((i+1)*step, N), Results, Counters);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
#else
    // Print debug in serial code to get coherent trace output

    // for(int i=0; i<Nworkers; i++){
    //   std::cout<<"multi_loss: Calling evolve_to_target_and_save i=" << i << " N=" << N << " step=" << step << " istart=" << i*step
    //            << " iend=" << (i+1)*step << "\n";
    // }

    // Execute actual loop in parallel

#pragma omp parallel for private (i)
    for(int i=0; i<Nworkers; i++){
      un[i]->evolve_to_target_and_save(i*step, min((i+1)*step,N), Results, Counters);
    }
#endif

    for (int i=0; i<N; i++){
      
      Loss+=Results[i]/(double)N;
      LossSquare+=Results[i]*Results[i]/(double)N;

    }

    double two_std = ((LossSquare - Loss*Loss)/(double)N);

    two_std = 2.*sqrt(two_std);
    std::pair<double,double> Res;
    Res.first=Loss;
    Res.second=two_std;

    //gettimeofday(&endTime, NULL);
    //elapsedTime = timediff_s(startTime, endTime);
    // cout << "multi_loss(N=" << N << ", target=" << un[0]->get_target() << ") elapsed time: " << elapsedTime << " seconds " << elapsedTime/60. << " minutes\n\n";

    return Res;


  }
//============================================================


//============================================================

  void multi_annealing( dispatch_group_t group,
                        Universe* un[],
                        dispatch_queue_t* CustomQueues,
                        double T_start, double T_end,
                        double Target_rejection,
                        int Annealing_repeats,
                        double starting_jump,
                        double* Results,
                        int*    Counters,
                        double* params0,
                        double annealing_cycles){
      //.................................
      // re-implement annealing

      double dx[5]={0.,0.,0.,0.,0};
      double x[5]={0.,0.,0.,0.,0};
      double rejection[5]={0., 0., 0., 0., 0.};
      double curr_x, curr_err, x_tmp;
      double temperature;
      double ratio, r;
      int cycle=10;
      //boost::variate_generator<base_generator_type&, boost::uniform_real<> > uni(generator, uni_dist);

      // set up parameter for annealing

      x[0]=params0[0];
      x[1]=params0[1];
      x[2]=params0[2];
      x[3]=params0[3];
      x[4]=params0[4];

      for(int i=0;i<5;i++){
        dx[i] = starting_jump;
      }

      // establish the current value
      std::pair<double,double>Res;

      Res = multi_loss(group, un, CustomQueues, Results, Counters, x);
      std::cout << Res.first << " +- " << Res.second << std::endl;

      if ( operation == 'm' ) {
        FILE *f;
        int N = un[0]->get_reruns();

        f = fopen("multi_loss.data","w");
        for(int i=0; i<N; i++) {
          fprintf(f,"%.20e\n",Results[i]);
        }
        fclose(f);
        exit(0);
      }

      curr_x   = Res.first;
      curr_err = Res.second;

      // optimization cycle

      for(int i=0; i<annealing_cycles; i++){

        temperature = T_start*exp( i*(log(T_end)-log(T_start))/(double)annealing_cycles);
        std::cout  << std::endl << "....T = " << wrap_double(temperature,3) << std::endl << std::endl;

        if (i % cycle == 0 && i > 0){

          for (int k=0; k<5; k++){
            rejection[k]/=(double)cycle;

            if (rejection[k] > 0){
              dx[k] = dx[k]/(rejection[k]/Target_rejection);
              rejection[k]=0.;
            }
            else{
              dx[k]*=2.;
            }
            std::cout  << dx[k] << " ";
          }
          std::cout  << std::endl;
        }


        for (int j=0; j<5; j++){

          ///////////////////////////////
          if (FIX_VARIABLES==0 || var_fixed[j]==0){



            // get new value of x[j]
            double x_hold=x[j];
            x_tmp = get_new_x(x[j],dx[j]);
            x[j]=x_tmp;

            std::cout << wrap_double(x_tmp,10) << " " << wrap_double(j,9) << "\n\n";
            //=======================================
            //.............................................
            for(int w=0; w<Nworkers; w++){
              un[w]->set_parameter(x_tmp, j);
            }

            
            Res = multi_loss(group, un, CustomQueues, Results, Counters, x);
            std::cout << Res.first << " +- " << Res.second << std::endl;

            ratio = min(1.,exp(-(Res.first-curr_x)/temperature));
            r = rand()/(double)(pow(2.,31)-1.);
            std::cout << r << " vs " << ratio << std::endl;

            double ALOT=100000000000.;

            if (Res.first < ALOT)
            {
              ofstream filestr;

              filestr.open ("best_opt_some.txt", ofstream::app);

              // >> i/o operations here <<
              filestr << un[0]->get_target() << ","
                << Res.first
                << "," << un[0]->get_parameter(0)
                << "," << un[0]->get_parameter(1)
                << "," << un[0]->get_parameter(2)
                << "," << un[0]->get_parameter(3)
                << "," << un[0]->get_parameter(4) << "," << Res.second << ",\n";

              filestr.close();


              //filestr.open ("max_dist.txt", ofstream::app);

              // >> i/o operations here <<
              // filestr << max_dist << ",\n";

              //filestr.close();

              FILE *bf;
              bf = fopen("bestdb.txt","a");
              fprintf(bf, "N %2d %2d %10.5f %5.2f | %5.2f %10.5f [ %5.2f %5.2f %10.5f %10.5f %10.5f ] %10.5f\n", i, j, dx[j], rejection[j],
                      un[0]->get_target(),
                      Res.first,
                      un[0]->get_parameter(0),
                      un[0]->get_parameter(1),
                      un[0]->get_parameter(2),
                      un[0]->get_parameter(3),
                      un[0]->get_parameter(4),
                      Res.second);
              fclose(bf);
            }


            if (r > ratio){

              std::cout << " "<< (i+1) << ","<< (j)
                        <<" "<< (i+1) << " Did not accept "
                        << x_tmp << "(" << j << ")" << std::endl;
              std::cout << un[0]->get_parameter(0)
                        << " " << un[0]->get_parameter(1)
                        << " " << un[0]->get_parameter(2)
                        << " " << un[0]->get_parameter(3)
                        << " " << un[0]->get_parameter(4) << " " << std::endl;

              x[j]=x_hold;
              for(int w=0; w<Nworkers; w++){
                un[w]->set_parameter(x[j], j);
              }


              //set_parameter(x[j], j);
              rejection[j]+=1.;
            }

            else {

              curr_x   = Res.first;
              curr_err = Res.second;
              x[j] = x_tmp;

              for(int w=0; w<Nworkers; w++){
                un[w]->set_parameter(x[j], j);
              }

              std::cout << (i+1) << string_wrap((string) " Rejection counts: ", 8)
                        << wrap_double(rejection[0],6) << " "
                        << wrap_double(rejection[1],7) << " "
                        << wrap_double(rejection[2],5) << " "
                        << wrap_double(rejection[3],9) << " "
                        << wrap_double(rejection[4],6) << " "
                        << std::endl << std::endl;

              std::cout << " "<< (i+1) <<","<< (j)
                        <<" "
                        << string_wrap((string) "***** Did accept! ", 3)
                        << wrap_double(un[0]->get_parameter(0),6) << " "
                        << wrap_double(un[0]->get_parameter(1),7) << " "
                        << wrap_double(un[0]->get_parameter(2),5) << " "
                        << wrap_double(un[0]->get_parameter(3),9) << " "
                        << wrap_double(un[0]->get_parameter(4),6) << " "
                        << std::endl << std::endl;



            }
            //........................................................

          }
        }

      }

    }



