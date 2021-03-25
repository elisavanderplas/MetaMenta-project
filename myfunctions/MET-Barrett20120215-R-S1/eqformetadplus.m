function x=eqformetadplus(y)

% y(1)=meta-tauplus; y(2)=meta-d'_+

global th hp fp ssigma

x(1)=(1-cdf('Normal',y(1),y(2),ssigma))/(1-cdf('Normal',th*y(2),y(2),ssigma))-hp;
x(2)=(1-cdf('Normal',y(1),0,1))/(1-cdf('Normal',th*y(2),0,1))-fp;