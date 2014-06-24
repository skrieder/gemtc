# the compiler: gcc for C program, define as g++ for C++
CC = nvcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -G -arch=sm_20

# the build target executable:
TARGET1 = bigcuda3
TARGET = bigcuda2

all: $(TARGET) $(TARGET1)

$(TARGET): $(TARGET).cu
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).cu

$(TARGET1): $(TARGET1).cu
	$(CC) $(CFLAGS) -o $(TARGET1) $(TARGET1).cu

clean:
	$(RM) $(TARGET)
	$(RM) $(TARGET1)
