function x=eqformetadminus(y)

% y(1)=meta-tauminus; y(2)=meta-d'_-

global th hm fm ssigma

x(1)=cdf('Normal',y(1),0,1)/cdf('Normal',th*y(2),0,1)-hm;
x(2)=cdf('Normal',y(1),y(2),ssigma)/cdf('Normal',th*y(2),y(2),ssigma)-fm;