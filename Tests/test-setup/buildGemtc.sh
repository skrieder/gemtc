# Step 1:
echo "Step 1: Compiling our library source into PIC."
echo "gcc -fPIC -c gemtc_setup.c -o gemtc_setup.o"
gcc -fPIC -c gemtc_setup.c -o gemtc_setup.o
# Step 2:
echo "Step 2: Turn the object file into a shared library." 
echo "gcc -shared -o libgemtc.so gemtc_setup.o -L. -ltest"
gcc -shared -o libgemtc.so gemtc_setup.o -L. -ltest
# Step 3:
echo "Step 3: Linking with a shared library." 
echo "gcc -L. -Wall -o test gemtc_setup.c -lgemtc"
gcc -L. -Wall -o test gemtc_setup.c -lgemtc
# Step 4:
echo "Step 4: Running the program to test it."
echo "./test"
./test
