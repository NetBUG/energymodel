function [x, r_norms] = tgcr(A,b,tol,maxiters) 
% Generalized conjugate residual method for solving Ax = b
% INPUTS
% A - matrix
% b - right hand side
% tol - convergence tolerance, terminate on norm(b - Ax) < tol * norm(b)
% maxiters - maximum number of iterations before giving up 
% OUTPUTS
% x - computed solution, returns null if no convergence
% r_norms - the scaled norm of the residual at each iteration (r_norms(1) = 1)

% Generate the initial guess for x (zero)
x = zeros(size(b));

% Set the initial residual to b - Ax^0 = b
r = b;

% Determine the norm of the initial residual
r_norms = zeros(maxiters+1,1);
r_norms(1) = norm(r,2);

p = zeros(length(b),maxiters);
Ap = p;

for iter = 1:maxiters
% Use the residual as the first guess for the new
% search direction and multiply by A
  p(:,iter) = r; 
  Ap(:, iter) = A * p(:,iter);
  
% Make the new Ap vector orthogonal to the previous Ap vectors,
% and the p vectors A^TA orthogonal to the previous p vectors
  for j=1:iter-1, 
    beta = Ap(:,iter)' * Ap(:,j); 
    p(:,iter) = p(:,iter) - beta * p(:,j); 
    Ap(:,iter) = Ap(:,iter) - beta * Ap(:,j);
  end; 

% Make the orthogonal Ap vector of unit length, and scale the
% p vector so that A * p  is of unit length
  norm_Ap = norm(Ap(:,iter),2);
  Ap(:,iter) = Ap(:,iter)/norm_Ap;
  p(:,iter) = p(:,iter)/norm_Ap;

% Determine the optimal amount to change x in the p direction
% by projecting r onto Ap
  alpha = r' * Ap(:,iter);

% Update x and r
  x = x + alpha * p(:,iter); 
  r = r - alpha * Ap(:,iter); 

% Save the norm of r
  r_norms(iter+1) = norm(r,2); 

% Print the norm during the iteration 
% fprintf('||r||=%g i=%d\n', r_norms(iter+1), iter+1);

% Check convergence.
  if r_norms(iter+1) < (tol * r_norms(1))
    break 
  end
end

% Notify user of convergence
if r_norms(iter+1) > (tol * r_norms(1))
   fprintf(1, 'GCR NONCONVERGENCE!!!\n');
  x = [];
else 
   fprintf(1, 'GCR converged in %d iterations\n', iter);
end; 

% Scale the r_norms with respect to the initial residual norm
r_norms = r_norms / r_norms(1);


