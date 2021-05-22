clear; clc; close all;
%% 训练数据初始化
vecLen=2;%特征维度
sampleN=30;%各类样本数据个数
[Xin,Yd] = sample_create(sampleN);

%% 产生神经网络
net = create_net(3,[vecLen,5,1],...%产生和初始化神经网络，3层，各层分别为2、5、1个节点
    1e-3,500*sampleN,0.1,0.0);%设定各个迭代控制参数
%此处可以直接修改net的属性用于迭代

%% 训练网络
net1 = net_train_per(net,Xin,Yd);%逐个样本训练
net2 = net_train_mass(net,Xin,Yd);%成批样本训练


figure('Name','误差曲线');
plot(net1.ErrIter,'b.-'),hold on; grid on
plot(net2.ErrIter,'rx-');
ylim([min([net1.ErrIter(end),net2.ErrIter(end)]),max([net1.ErrIter(1),net2.ErrIter(1)])]);
legend('逐个样本修正','成批样本修正');xlabel('迭代次数');ylabel('均方误差');
