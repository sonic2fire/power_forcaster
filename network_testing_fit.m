clear all; close all;
load('training')

alorigithm = 'trainbr';
input_training = [training(1:52273,1:2) training(1:52273,4:7)]';
output_training = [training(1:52273,3)]';

input_testing = [training(52273:52417,1:2) training(52273:52417,4:7)]';
actual = [training(52273:52417,3)]';

%net2 = feedforwardnet(2,alorigithm);
net3 = feedforwardnet(3,alorigithm);
net4 = feedforwardnet(4,alorigithm);
net5 = feedforwardnet(5,alorigithm);
%net6 = feedforwardnet(6,alorigithm);
%net7 = feedforwardnet(7,alorigithm);
%net8 = feedforwardnet(8,alorigithm);
%net9 = feedforwardnet(9,alorigithm);

%[net2, tr] = train(net2, input_training, output_training);
[net3, tr] = train(net3, input_training, output_training);
[net4, tr] = train(net4, input_training, output_training);
[net5, tr] = train(net5, input_training, output_training);
%[net6, tr] = train(net6, input_training, output_training);
%[net7, tr] = train(net7, input_training, output_training);
%[net8, tr] = train(net8, input_training, output_training);
%[net9, tr] = train(net9, input_training, output_training);

%values(1,1:301) = net2(input_testing);
values(1,1:145) = net3(input_testing);
values(2,1:145) = net4(input_testing);
values(3,1:145) = net5(input_testing);
%values(5,1:301) = net6(input_testing);
%values(6,1:301)= net7(input_testing);
%values(7,1:301)= net8(input_testing);
%values(8,1:301)= net9(input_testing);

figure
hold on
for(i=1:3)
    
    plot(values(i,:))

end
plot(actual)

legend('3-nodes','4-nodes','5-nodes','actual')
%legend('2-nodes','3-nodes','4-nodes','5-nodes','6-nodes','7-nodes','8-nodes','9-nodes','actual')

for(i=1:3)
    in = ((values(i,:) - actual).^2);
    in(isnan(in))=[];
    errort(i) = sqrt((1/length(values(i,:)))*sum((in)));
end

errort



