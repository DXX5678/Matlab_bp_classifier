function net = net_train_mass(net,Xin,Yd)
%% 根据输入训练样本，修正网络节点权值（成批样本修正），采用BP算法，参数：
% net 神经网络，权值修正前后
% Xin 输入样本，[样本数x特征维度] 的矩阵
% Yd 理想输出分类

%% 参数初始化
% 迭代参数
minErr = net.minErr;%误差界
maxIter = net.maxIter;%最多迭代次数

% 计算所需参数
lNum = net.lNum;%层数
pNum = net.pNum;%各层的节点数目

% 迭代参数
ErrIter = [];%误差记录
sampleN = size(Xin,1);%输入样本数量

%% BP算法（成批样本修正）
Errtmp = inf;%初始误差
for k = 1:maxIter%*sampleN%可以保证循环完成
    p = mod(k-1,sampleN)+1;%当前轮样本标号
    %% 从前向后计算各个单元输出直到最后一个
    xin = Xin(p,:)';%本次输入变量
    yd = Yd(p,:)';%本次理想输出
    [yo,layer_out{p}] = net_test(net, xin);%计算各个输入样本的各层输出
    
    %% 终止判断
    yerr = yd - yo; %最终分类误差
    if p == 1 %本轮刚开始
        Errtmp = Errtmp/sampleN;%误差均值
        ErrIter = [ErrIter,Errtmp];%保存上一轮轮误差
        if Errtmp<minErr
            break;%终止迭代求解
        end
        Errtmp = sum(yerr.^2);
    else%本轮样本正在循环
        Errtmp = Errtmp + sum(yerr.^2);%累计误差
    end
    
    %% 从后向前各层依次计算误差，并最后用于成批修正权值
    err_out{p} = net_err(net,layer_out{p},yd);
    if p == sampleN %完成一轮，批量修正权值
        net.w = net_back_adjust(net,layer_out,err_out);
    end
    
    
end
net.ErrIter = ErrIter;%迭代误差曲线，用于绘制收敛速度对比

fprintf('终止误差=%1.4e,  迭代步数=%d\n',ErrIter(end),k);
end

function [y,layer_out] = net_test(net,x)
%% 根据net计算向量x的输出y以及各层的输出layer_out
sigmoid = @(x) (1./(1+exp(-x)));%函数声明

layer_out{1} = x;%X必须是一个一维向量
for k=2:net.lNum
    %依次计算各层的输出
    w = net.w{k-1};%前一层->当前层的权值向量
    layer_out{k} = sigmoid(w*layer_out{k-1});%当前层输出
end
y = layer_out{net.lNum};
end


function err_out = net_err(net,layer_out,yd)
%% 计算各层误差
N = length(layer_out);%层数

%% 计算各层的输出误差
err_out{N} = -layer_out{N}.*(1-layer_out{N}).*(yd - layer_out{N});%输出层
for k=(N-1):-1:1
    errTmp = net.w{k}'*err_out{k+1} ;%后一层误差和映射到当前层各个节点
    err_out{k} = layer_out{k}.*(1-layer_out{k}).*errTmp;%书上公式
end

end


function wadj = net_back_adjust(net,layer_out,err_out)
%% 反向利用误差校正权值
enta = net.enta;%步长，通常0-1之间
alpha  = net.alpha;%惯性系数，0-1之间
sampleN = length(layer_out);%采样点数
N=length(layer_out{1});%层数

%% 权值修正
for m=(N-1):-1:1%对各层
    deltaw = 0;%初始化
    for n=1:sampleN%对各个样本求和
        deltaw = deltaw -enta*err_out{n}{m+1}*layer_out{n}{m}';
    end
    net.deltaw{m} = deltaw + net.deltaw{m}*alpha;%上一步的惯性也加上了
    wadj{m} = net.w{m} + net.deltaw{m};%权值修正
end

end