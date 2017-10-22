function PlotLearningRate(epochList,tssList, learnRate, momentum)
plot(epochList, tssList);
xlabel('epochs'); 
ylabel('MSE') ;
title(strcat('Plot of the MSE Vs Epochs for learning rate: ', num2str(learnRate), ' and momentum: ', num2str(momentum)));
legend('MSE curve');