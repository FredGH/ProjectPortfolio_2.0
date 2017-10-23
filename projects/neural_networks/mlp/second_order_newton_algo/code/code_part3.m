clearvars variables
%**************************************************************************
%****************Load the data (1=sun spot time series) *******************
%**************************************************************************
load TrainingData_Assign1.dat;
load TrainingLabels_Assign1.dat;
Patterns = TrainingData_Assign1';
Desired = TrainingLabels_Assign1';

%**************************************************************************
%*************************** SET UP ***************************************
%**************************************************************************
NEPOCH = 300; % The initial number of epoch
NHIDDEN = 3; %Number of hidden nodes
weights = [-0.25 0.33 0.14 -0.17 0.16 0.43 0.21 -0.25];
mseList = []; epochList =[]; TSS_Limit = 0.02;
[NINPUTS,NPATS] = size(Patterns);
[NOUTPUTS,NPATS] = size(Desired);
Inputs1 = [Patterns]; 
Inputs1Trans = Inputs1'; 
Out_list = zeros(1,2);

%**************************************************************************
%*************************** TRAIN  ***************************************
%**************************************************************************
for epoch = [1:NEPOCH]
    fprintf('********** Epoch %1d **********\n',epoch);
    epochList(epoch) = epoch;
    TSS = 0;
    deltaW1 = 0; deltaW2 = 0; deltaW1Perceptron = 0;
    G1 =0; G2 =0; G1Perceptron = 0;
    jacobian =0; currentHess =0;H1=0;H2=0;

    Weights1 = [weights(1) 0  weights(3) ; 0  weights(4)  weights(5)]; 
    Weights1_Perceptron = [weights(2)]; 
    Weights2 = [weights(6) weights(7) weights(8)];

    fprintf('********** Weights **********\n');
    fprintf('Weights1:\n');
    disp(Weights1)
    fprintf('Weights1_Perceptron:\n');
    disp(Weights1_Perceptron)
    fprintf('Weights2:\n');
    disp(Weights2)

    %For each example
    for ex=1:NPATS
      fprintf('***Example %1d\n',ex);

      %Hidden Forward Propagation  
      NetIn1 = Weights1' * Inputs1(:,ex); 
      Hidden = 1.0 ./( 1.0 + exp( -NetIn1 )); 
      %Output Forward Propagation
      Inputs2 = Hidden;
      Out_Hidden = Weights2 * Inputs2 
      fprintf('Out_Hidden = %0.4f\n',Out_Hidden);
      %Perceptron Propagation
      Out_Perceptron =  Weights1_Perceptron * Inputs1(1,ex);
      fprintf('Out_Perceptron = %0.4f\n',Out_Perceptron);
      %Output
      Out = Out_Hidden + Out_Perceptron;
      Out_list(ex) = Out;
      fprintf('Out = %0.4f\n',Out);
      
      %Errors/Beta Backward Propagation
      Error = Desired(ex) - Out;
      Beta = 1.0;      
      fprintf('Beta = %0.4f\n',Beta);
      fprintf('Error = %0.4f\n',Error);
      %HiddenBeta and Deriv Backward Propagation
      bperr = Weights2' * Beta;
      HiddenBetaDeriv = Hidden .* (ones(NHIDDEN,1) - Hidden);
      HiddenBeta = HiddenBetaDeriv .* bperr;
      PrintHiddenBetas(HiddenBeta)
      %Hidden ->  Ouput  dW and gdW Backward Propagation
      dW2h = Beta * Inputs2' ;
      grad2 = Error * dW2h;
      %Input ->  Hidden  dW and gdW Backward Propagation
      dW1h = 0;grad1 =0; idx =1;
      for idx_i= 1:NINPUTS
        for idx_h=1:NHIDDEN
            if (Weights1(idx_i,idx_h) ~= 0) 
                 factor = 1; 
             else
                 factor = 0 ;
             end
             dW1h(idx) = HiddenBeta(idx_h) * Inputs1(idx_i,ex) * factor;
             grad1(idx) =  Error * dW1h(idx);
             idx = idx +1;
          end
      end
      %Perceptron ->  Ouput  dW and gdW Backward Propagation
      dW1hPerceptron = Beta * Inputs1Trans(ex,1);
      grad1Perceptron =  Error * dW1hPerceptron;

      %Accumulate the jacobian
      H1 = H1 + dW1h;
      H2 = H2 + dW2h;
      %Gradient Descent      
      G2 = grad2 + G2; 
      G1 = grad1 + G1; 
      G1Perceptron = grad1Perceptron + G1Perceptron;
      
      %TSS errors:
      TSS = TSS + sum( Error^2 );
      fprintf('TSS = %0.4f\n', TSS);
      
      jacobian = [dW1h(1) dW1hPerceptron dW1h(3) dW1h(5) dW1h(6) dW2h ];
      currentHess = currentHess + ((jacobian') * (jacobian)); 
    end
    
    G = [G1(1) G1Perceptron G1(3) G1(5) G1(6) G2]/ NPATS;
    hess = currentHess / NPATS;
    hess = hess + (eye ([ size(hess) ]) * 0.001);
    newtonDeltaWeights = inv( hess ) * G';
    
    weights = weights + newtonDeltaWeights'; 
    
    %RMSE
    RMSE =0;
    if (TSS ~= 0) 
        RMSE = sqrt(TSS/NPATS);
    end
    mseList(epoch) = RMSE;
    fprintf('---> RMSE = %0.4f\n',RMSE);
    
    %Stop when convergence is achieved 
    %(i.e delta weights are close to 0)
    %if TSS < TSS_Limit, break, end
    if (newtonDeltaWeights' < repmat(0.0001,1,size(weights,2)))
        fprintf('---> newtonDeltaWeights = %0.4f\n',newtonDeltaWeights);
        break
    end
end

%Plot Learning Rate
PlotRmse(epochList,mseList);
