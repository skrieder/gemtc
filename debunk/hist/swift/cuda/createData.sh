max=$1
str="0"
for i in $(seq 1 $max)
do
	j=$(( $i % 256))
	str="$str $j" 
done

/home/skrieder/sfw/turbine/bin/turbine-write-doubles input.data  $str
