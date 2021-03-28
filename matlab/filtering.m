clear; format short e
fname = 'core_patch_fluctuation_mold_patch_trial1.csv';
data = readtable(fname);
temp = data.Var1;
figure(1);clf
plot(1:size(temp),temp,'k-')
hold on
h2 = tf([1],[7 1]);
plot(1:size(temp),lsim(h2,temp,0:size(temp)-1),'r-')
axis([0 8000 32 40])
avg = movmean(temp,10);
plot(1:size(temp),avg,'m--')
h2sim = lsim(h2,temp,0:size(temp)-1);
simdif = avg(200:end)-h2sim(200:end);
difmax = max(abs(simdif));
fprintf('Max difference between moving average and filtered data is %0.3f C\n',difmax)
figure(2);clf
alpha = 0.15;
tsize = numel(temp);
ewma = zeros(1,tsize);
for k = 1:tsize
    if k==1
        ewma(k) = temp(k);
        continue
    end
    ewma(k) = alpha * temp(k) + (1-alpha)*ewma(k-1);
end
plot(1:tsize,ewma,'b-')
hold on
plot(1:tsize,temp,'k-')
ewmadif = avg - ewma.';
ewmax = max(abs(ewmadif));
fprintf('Max difference between moving average and ewma is %0.3f C\n',ewmax)