function tsp
L = [17.69 19.28 10.17 18.63 18.45;
     15.81 15.8 11.21 14.84 12.1]

W = [0 1.59 8.82 1.35 3.787;
     1.59 0 10.2 1.16 3.79;
     8.82 10.2 0 9.21 8.33;
     1.35 1.16 9.21 0 2.75;
     3.787 3.79 8.33 2.75 0]
 
 T = [1 4 2 5 3;
      4 2 5 3 1;
      1.35 1.16 3.79 8.33 8.82]
load('tsp_instance.mat')

tsp_skeleton(L)
end