function PlotBpPats(P,D)
% PLOTPATS   Plots the training patterns defined by Patterns and Desired.
%
%            P - MxN matrix with N patterns of length M.
%		 The first two values in each pattern are used 
%		 as the coordinates of the point to be plotted.
%
%            D - QxN matrix with N desired -1/+1 output patterns
%		 of length Q.  The first 2 bits of the output pattern
%		 determine the class of the point: o, +, *, or x.

if nargin ~=2
  error('Wrong number of arguments.');
  end

[M,N] = size(P);
Q = size(D,1);
D = (D+1)/2;

if Q<2, D=[D;zeros(1,N)];,end

clf reset, whitebg(gcf,[0 0 0])
hold on

% Calculate the bounds for the plot and cause axes to be drawn.
xmin = min(P(1,:)); xmax = max(P(1,:)); xb = (xmax-xmin)*0.2;
ymin = min(P(2,:)); ymax = max(P(2,:)); yb = (ymax-ymin)*0.2;
axis([xmin-xb, xmax+xb,ymin-yb, ymax+yb]);
title('Hidden Unit Input Classification');
xlabel('x1'); ylabel('x2');

class = 1 + D(1,:) + 2*D(2,:);
colors = [1 0 0; 1 1 0; 0 1 0; 0 0 1];
symbols = 'o+*x';

for i=1:N
  c = class(i);
  plot(P(1,i),P(2,i),symbols(c),'Color',colors(c,:));
  end