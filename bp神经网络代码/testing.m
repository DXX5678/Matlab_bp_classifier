%% 模拟测试样本
sampleN=30;%各类样本数据个数
[Xin,Yd] = sample_create(sampleN);
%% 识别样本
yo1 = net_test(net1,Xin);%逐个样本修正
yo1 = yo1>=0.5;
per1 = sum(yo1 ~=Yd)/length(Yd);
yo2 = net_test(net2,Xin);%成批样本修正
yo2 = yo2>=0.5;
per2 = sum(yo2 ~=Yd)/length(Yd);
[per1,per2]