# Step 1:
# Compile our library source code into position-independent code (PIC)
echo "Step 1: Compiling into PIC." 
gcc -c -Wall -Werror -fpic foo.c
# Step 2:
# Compile our library source code into position-independent code (PIC)
echo "Step 2: Turn the object file into a shared library." 
gcc -shared -o libfoo.so foo.o
# Step 3:
# Compile our library source code into position-independent code (PIC)
echo "Step 3: Linking with a shared library." 
gcc -L. -Wall -o test main.c -lfoo
# Step 4:
# Test the application by running it.
echo "Running the program to test it."
./test