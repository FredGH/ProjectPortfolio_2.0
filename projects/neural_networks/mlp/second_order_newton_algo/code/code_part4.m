% by Dave Touretzky (modified by Nikolay Nikolaev/Frederic Marechal)
% https://www.cs.cmu.edu/afs/cs/academic/class/15782-f06/matlab/

%**************************************************************************
%****************Load the data (1=sun spot time series) *******************
%**************************************************************************
load sunspot.dat
year=sunspot(:,1); relNums=sunspot(:,2); %plot(year,relNums)
ynrmv=mean(relNums(:)); sigy=std(relNums(:)); 
nrmY=relNums; %nrmY=(relNums(:)-ynrmv)./sigy; 
ymin=min(nrmY(:)); ymax=max(nrmY(:)); 
relNums=2.0*((nrmY-ymin)/(ymax-ymin)-0.5);
% create a matrix of lagged values for a time series vector
Ss=relNums';
idim=10; % input dimension
odim=length(Ss)-idim; % output dimension
for i=1:odim
   y(i)=Ss(i+idim);
   for j=1:idim
       x(i,idim-j+1)=Ss(i-j+idim);
   end
end

%**************************************************************************
%*************************** SET UP ***************************************
%**************************************************************************
NHIDDENS = 5; %The number of hidden layers
NSTW = 5; % The number of sliding time windows
NEPOCH = 100; % The initial number of epoch
NEPOCH_RATE = 0.5; %The rate of increase/decrease of epoch after each simulation 
MAX_TRAIN_INDEX = 200; %The training last index 
LearnRate = 0.001; Momentum = 0; DerivIncr = 0; deltaW1 = 0; deltaW2 = 0;
Weights1 =  [ 0.0537   -0.0749   -0.1218   -0.1176   -0.0103    0.1105   -0.1952    0.1318   -0.1540    0.0152;
             -0.0249    0.0810    0.0567   -0.0910    0.0697    0.0112   -0.2182    0.0639   -0.1806    0.1806;
             -0.0206   -0.0419    0.0411   -0.1904    0.0224    0.2469   -0.0477    0.1360    0.0981   -0.0076;
             0.0810    0.1710    0.0204    0.2199    0.0737   -0.1407   -0.0258    0.2164   -0.2031   -0.0533;
             0.1351    0.1665    0.1850    0.0728    0.0219   -0.1971   -0.0671    0.2364    0.0127    0.0857]
Weights2 = [0.0414    0.1577    0.1895    0.2445   -0.2497]
%Weights1 = 0.5*(rand(NHIDDENS,1+NINPUTS)-0.5);
%Weights2 = 0.5*(rand(1,1+NHIDDENS)-0.5); 

rmseList = [ ];
rmseList = [{'Sliding Window'} ,{'RMSE_Training'} , {'RMSE_Test'}]
Patterns = x'; 
Desired = y; 
prnout=Desired;
[NINPUTS,NPATS] = size(Patterns); [NOUTPUTS,NP] = size(Desired);
Inputs1= [Patterns]; 
slidingWindowList = []; 
rmseTrainingList = [];rmseTestList = [];
mapeTrainingList = [];mapeTestList = [];
OutPredList = [];
DesiredOneDayPredList = [];

%**************************************************************************
%*************************** TRAIN & PREDICT ***************************************
%**************************************************************************
for slidWinIndex = [1:NSTW]
    fprintf('***************************\n')
    fprintf('slidWinIndex %3d:  Nb Epochs = %f\n',slidWinIndex,NEPOCH);
    fprintf('***************************\n')
    startIndex = slidWinIndex;
    endIndex = MAX_TRAIN_INDEX -1+ slidWinIndex;
    %Create the sliding window
    Inputs1SldWin = Inputs1(1:NINPUTS, startIndex:endIndex) 
    DesiredSldWin = Desired(1:NOUTPUTS,startIndex:endIndex)  
    [NINPUTS,NPATS] = size(Inputs1SldWin)
    for epoch = 1:NEPOCH
      % Forward propagation
      NetIn1 = Weights1 * Inputs1SldWin;
      %Hidden=1-2./(exp(2*NetIn1)+1);
      Hidden = 1.0 ./( 1.0 + exp( -NetIn1 )); 
      Inputs2 = [Hidden];
      NetIn2 = Weights2 * Inputs2;
      Out = NetIn2;
      prnout=Out;
      % Backward propagation of errors
      Error = DesiredSldWin - Out;
      TSS = sum(sum( Error.^2 )); 
      MAPE = sum(sum(abs(Error/DesiredSldWin)));
      Beta = Error;
      bperr = ( Weights2' * Beta );
      %HiddenBeta = (1.0 - Hidden .^2 ) .* bperr(1:end,:);
      HiddenBeta = (Hidden .* (ones(NHIDDENS,NPATS) - Hidden)).* bperr(1:end,:);
      % Calculate the weight updates:
      dW2 = Beta * Inputs2';
      dW1 = HiddenBeta * Inputs1SldWin';
      deltaW2 = LearnRate * dW2 + Momentum * deltaW2;
      deltaW1 = LearnRate * dW1 + Momentum * deltaW1;
      % Update the weights:
      Weights2 = Weights2 + deltaW2;
      Weights1 = Weights1 + deltaW1;
      %fprintf('Epoch %3d:  Error = %f\n',epoch,TSS);
      %if TSS < TSS_Limit, break, end
    end
    RMSETrain = sqrt(TSS/NPATS);
    MAPETrain =  (100/ NPATS) * MAPE;
    
    slidingWindowList (slidWinIndex) =  year(1) + NPATS + slidWinIndex
    rmseTrainingList(slidWinIndex) = RMSETrain;
    mapeTrainingList(slidWinIndex) = MAPETrain;
    
    %Create the input vs desired set for a one day prediction 
    Inputs1OneDayPred = Inputs1(1:NINPUTS, endIndex+1) 
    DesiredOneDayPred = Desired(1:NOUTPUTS,endIndex+1)
    [NINPUTS,NPATS1] = size(Inputs1OneDayPred)
    %Generate the prediction using forward propagation 
    NetIn1 = Weights1 * Inputs1OneDayPred;
    Hidden = 1.0 ./( 1.0 + exp( -NetIn1 )); 
    %Hidden=1-2./(exp(2*NetIn1)+1); 
    Inputs2 = Hidden;
    Out = Weights2 * Inputs2;
    %Generate the RMSE for a one day prediction 
    Error = DesiredOneDayPred - Out;
    OutPredList(slidWinIndex) = Out;
    DesiredOneDayPredList(slidWinIndex) = DesiredOneDayPred;
    TSSTest = sum(sum( Error.^2 ));
    RMSETest = sqrt(TSSTest/NPATS1);
    rmseTestList (slidWinIndex) = RMSETest;
    MAPETest =  (100/ NPATS1) * (abs(Error/DesiredOneDayPred));
    mapeTestList(slidWinIndex) = MAPETest;
  
    
    %Change the number of epochs for each simulation
    %NEPOCH = NEPOCH * NEPOCH_RATE
    %Print weights after simulation...
    fprintf ('Weights1:\n')
    disp(Weights1)
    fprintf ('Weights2:\n')
    disp(Weights2)
end

%Figure 
subplot(2,2,1)       
%plot(year(11:210),DesiredSldWin)
%title('Sunspot Data Initial')
%subplot(3,2,2)       
%plot(year(11:210),prnout, 'g')
%title('Sunspot Data Trained')
plot(year(11:210),DesiredSldWin,year(11:210),prnout)
title('Sunspot Data')

%Figure 
subplot(2,2,2)
plot(slidingWindowList,DesiredOneDayPredList,slidingWindowList,OutPredList)
title('Sunspot Data')
legend('Expected', 'Prediction')

%Figure 
subplot(2,2,3)       
plot(slidingWindowList, rmseTrainingList, slidingWindowList, rmseTestList)
title('Sunspot Data RMSE')
legend('Training', 'Test')

%Figure
subplot(2,2,4)       
plot(slidingWindowList, mapeTrainingList, slidingWindowList, mapeTestList)
title('Sunspot Data MAPE')   
legend('Training', 'Test')


%Results in a table
disp(rmseTrainingList)
disp(rmseTestList)
disp(mapeTrainingList)
disp(mapeTestList)
