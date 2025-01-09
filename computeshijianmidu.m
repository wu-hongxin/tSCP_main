function shijianmidu=computeshijianmidu(coverageM,coverageb)

%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
csize=size(coverageM,1);
num=zeros(csize,1);
a01=4000;
a02=1500;
a11=813;
a12=28728;
asum=a01+a02+a11+a12;
a01=a01/asum;
a02=a02/asum;
a11=a11/asum;
a12=a12/asum;


for i=1:csize
    if coverageb(i)==1
        x = coverageM(i,1);
        y = coverageM(i,2);
        if (0<= x ) &&(x <750) && (0<= y) && (y < 750)
            num(i)= a01;
        elseif (750<= x ) &&(x <= 1500)  && (0<= y) && (y < 750)
            num(i)= a02;
        elseif (0<= x ) &&(x <750) && (750<= y )&& (y <= 1500)
            num(i)= a11;
        else
             num(i)= a12;  
        end
            
        end
    
end
shijianmidu=num;
end



