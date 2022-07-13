 #!/bin/bash
for i in {1..20}
do
    matlab -nosplash -nodesktop -r "run('/home/martin/test_matlab.m');exit;" &
done
