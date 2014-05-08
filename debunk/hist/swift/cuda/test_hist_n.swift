import blob;
import io;

(blob sum) hist(blob v) "hist" "0.0"
[ "set <<sum>> [ hist::hist_tcl <<v>> ]" ];

main {
  file data = input_file("input.data");
  blob v = blob_read(data);
  int TEST = 10;
  //for(int i=0; i< TEST; i++){
  foreach i in [1:TEST] { 
    blob s = hist(v);
    floats_from_blob(s);
  }
}

