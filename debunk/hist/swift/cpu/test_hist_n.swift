import blob;
import io;

(blob sum) hist(blob v) "hist" "0.0"
[ "set <<sum>> [ hist::hist_tcl <<v>> ]" ];

main {
  file data = input_file("input.data");
  blob v = blob_read(data);
 foreach i in [1:5]{
  blob s = hist(v);
  floats_from_blob(s);
  }
}

