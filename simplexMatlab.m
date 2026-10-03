function [xSolution] = simplex(A,b,c)
  %A is the constraints, b is the other side of the equalities (or inequalities) and c is the coefficients of the objective function
  vars = size(A,2);
  constraints = size(A,1);

  numNB = vars - constraints;
  numBasic = vars - numNB;

  B = zeros(constraints, numBasic);
  N = zeros(constraints, numNB);
  Bidx = zeros(1,numBasic);
  Nidx = zeros(1, numNB);

  cN = zeros(1, numNB);
  cB = zeros(1, numBasic);

  xSolution = zeros(1, vars);

  kBtoBePivot = 0;
  jNtobePivot = 0;

  %pull from cols of A to be make a B matrix, make an N matrix from the remaining n-m cols
  %go back and pull from different cols of A to make B and try again if xB is not a BFS
  bfs = 1;
  while bfs == 1
    stayIn = 0;
    useVars = 1:vars

    for i = 1 : size(B,2)
      x = useVars(randi(length(useVars)))
      B(:,i) = A(:,x);
      useVars(x) = []
      Bidx(i) = x;
    endfor
    %check if that B matrix makes a BFS from xB = B^-1*b
    xB =  inv(B) * b

    for i = 1 : size(xB)
      if xB(i) < 0
        stayIn = 1
      endif
    endfor

    if stayIn = 0
      bfs = 0;
    endif
  endwhile

  %the remaining elements in useVars should be the indices to make N
  for i = 1 : size(useVars)
    N(:,i) = A(:,useVars(i));
    Nidx(i) = useVars(i);
  endfor

  for i = 1 : size(cN)
    cN(i) = c(Nidx);
  endfor

  for i = 1 : size(cB)
    cB(i) = c(Bidx);
  endfor

  %loop while r is not optimal, updating Bidx, Nidx, cB, cN, B, N is also inside this loop
  notOptimal = 1;
  while notOptimal == 1
    stayIn = 1;
    %construct xSolution
    for i = 1 : size(Bidx)
      xSolution(Bidx(i)) = xB(i);
    endfor

    for i = 1 : size(Nidx)
      xSolution(Nidx(i)) = 0;
    endfor

    %compute r vector and stop algorithm and return x = xB,xN if r is optimal
    reducedCost = cN - cB*inv(B)*N;
    for i = 1 : size(reducedCost)
      if reducedCost(i) < 0
        stayIn = 0;
      endif
    endfor

    if stayIn == 1
      return xSolution;
    endif

    %if r is not optimal then find the smallest number in r and
    steepestDescent = intmax('int16');
    for i = 1 : size(reducedCost)
      if(reducedCost(i) < steepestDescent)
        steepestDescent = reducedCost(i);
      endif
    endfor

    findj = 0;
    for i : size(reducedCost)
      if reducedCost(i) == steepestDescent
        findj = i;
      endif
    endfor

    jNtobePivot = Nidx(findj);

    %compute direction
    dB = -inv(B) * N(findj);

    %create a vector for t from -xB/dB
    t = [];

    for i = 1 : size(dB)
      if dB(i) < 0
        t = [t, -dB(i)/xB(i)]
      endif
    endfor

    %find the index of the minimum value of t
    findk = 0;
    minIn_t = min(t);
    for i = 1 : size(t)
      if t(i) == minIn_t
        findk = i;
      endif
    endfor

    kBtoBePivot = Bidx(findk);

    %swap the approporiate cols
    save = B(:, kBtoBePivot);
    B(:,kBtoBePivot) = N(:, jNtobePivot);
    N(:,jNtobePivot) = save;

  endwhile

endfunction


