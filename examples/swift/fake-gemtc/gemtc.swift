import blob;

(int o) gemtc_sleep(int x)
  "gemtc" "0.0" "gemtc_sleep";

(blob b) gemtc_mdproxy(int np, blob pos)
  "gemtc" "0.0" "gemtc_mdproxy";


(float v[]) mdproxy_create_random_vector(int n)
{
  blob b = mdproxy_create_random_vector_blob(n);
  v = floats_from_blob(b);
}

(blob b) mdproxy_create_random_vector_blob(int n) "gemtc" "0.0"
[ "set <<b>> [ gemtc::mdproxy_create_random_vector <<n>> ]" ];

