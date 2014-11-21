#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -P cs451_s14_project
#$ -m n
#$ -pe mpich 1
#$ -S /bin/bash
#
/usr/bin/time -f "%e" ./mvect 2 4270 512 1
/usr/bin/time -f "%e" ./mvect 2 4271 512 1
/usr/bin/time -f "%e" ./mvect 2 4272 512 1
/usr/bin/time -f "%e" ./mvect 2 4273 512 1
/usr/bin/time -f "%e" ./mvect 2 4274 512 1
/usr/bin/time -f "%e" ./mvect 2 4275 512 1
/usr/bin/time -f "%e" ./mvect 2 4276 512 1
/usr/bin/time -f "%e" ./mvect 2 4277 512 1
/usr/bin/time -f "%e" ./mvect 2 4278 512 1
/usr/bin/time -f "%e" ./mvect 2 4279 512 1
/usr/bin/time -f "%e" ./mvect 2 4280 512 1
/usr/bin/time -f "%e" ./mvect 2 4281 512 1
/usr/bin/time -f "%e" ./mvect 2 4282 512 1
/usr/bin/time -f "%e" ./mvect 2 4283 512 1
/usr/bin/time -f "%e" ./mvect 2 4284 512 1
/usr/bin/time -f "%e" ./mvect 2 4285 512 1
/usr/bin/time -f "%e" ./mvect 2 4286 512 1
/usr/bin/time -f "%e" ./mvect 2 4287 512 1
/usr/bin/time -f "%e" ./mvect 2 4288 512 1
/usr/bin/time -f "%e" ./mvect 2 4289 512 1
#/usr/bin/time -f "%e" ./mvect 2 7 512 6000000
#/usr/bin/time -f "%e" ./mkvect 2 512 6000000
