function Plotm(epochList,tssList)
plot(epochList, tssList);
xlabel('epochs'); 
ylabel('RMSE') ;
title(strcat('Plot of the MSE Vs Epochs');
legend('RMSE curve');