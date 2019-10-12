kp=load('/Users/YiwenZhu/Desktop/KP_2019.txt');
is=zeros([586,1]);
is(kp(:,4)>=50)=60000;
is(kp(:,4)>=40 & kp(:,4)<=50)=500000;
is(kp(:,4)>=30 & kp(:,4)<=40)=400000;
is(kp(:,4)>=20 & kp(:,4)<=30)=300000;
is(kp(:,4)>=10 & kp(:,4)<=20)=200000;
is(kp(:,4)<=10)=100000;
kp(:,end+1)=is;
kp=kp';

fid=fopen('kp_2019.txt','w+');
fprintf(fid,'%d %d %d %d %d\n',kp);
fclose(fid);