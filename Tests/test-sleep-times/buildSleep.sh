# Step 1:
# Compile our library source code into position-independent code (PIC)
echo "Step 1: Compiling into PIC." 
gcc -c -Wall -Werror -fpic bar.c
# Step 2:
echo "Step 2: Turn the object file into a shared library." 
gcc -shared -o libbar.so bar.o
# Step 3:
echo "Step 3: Linking with a shared library." 
gcc -L. -Wall -o test-bar main.c -lbar
# Step 4:
# Test the application by running it.
echo "Step 4: Running the program to test it."
./test-bar