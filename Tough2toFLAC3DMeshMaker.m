 clear all
 disp('Prepare ELEME.txt and CONNE.txt File')
 disp('If any question,contact with QianlinZHU Zhuql@cumt.edu.cn')
%  a=input("Input Total Meshes in X Direct： ");
%  b=input("Input Total Meshes in Y Direct： ");
%  c=input("Input Total Meshes in Z Direct： ");
 disp('Please wait..... ')
 %  代码用于提取X坐标
fid=fopen('ELEME.txt');  %copy and creat eleme.txt file
tic
n=1;
while ~feof(fid)
    temp=fgetl(fid);  %% read line excluding newline character
    if length(temp)>5
        toughxyz{n,1}=temp(1:8); %tough2 grid number
        toughxyz{n,2}=temp(10:20); % material name used to group gird
        toughxyz{n,3}=str2double(temp(51:60)); % tough2 X-coordinates
        toughxyz{n,4}=str2double(temp(61:70)); % tough2 Y-coordinates
        toughxyz{n,5}=str2double(temp(71:80)); % tough2 Z-coordinates
        n=n+1;
    end                                           
end
clear n temp
fclose(fid);

% CONNE information 提取前后网格联结及离交接面距离 :
fid=fopen('CONNE.txt');
n=1;
while ~feof(fid)
    temp=fgetl(fid);
    if length(temp)>5
        TOUGHCNNE{n,1}=temp(1:8); %grid number 1
        TOUGHCNNE{n,2}=temp(9:16); %grid number2
        TOUGHCNNE{n,3}=str2double(temp(31:40)); % D1
        TOUGHCNNE{n,4}=str2double(temp(41:50)); % D2
        n=n+1;        
    end
end 
clear n temp
fclose(fid);
toc
%通过CONNE文件判断网格维数
n=1;
while n==str2double(TOUGHCNNE{n,1})
    n=n+1;
end
a=n;  %从起始，找CONNE中前面的单元第一次出现跳跃位置
clear n;

n=2;
[r1,~]=size(TOUGHCNNE);
diamxyz=1;
a1(3)=r1;
while n<=r1
      
    if strcmp(TOUGHCNNE{n,1},'00000001')
        a1(diamxyz)=n-1; 
        diamxyz=diamxyz+1;
      end
      n=n+1;
end
   a1(3)=a1(3)-a1(2);
   a1(2)=a1(2)-a1(1);
   c=a1(1)/(a-1)-a1(2)/a;
   b=a1(1)/(a-1)-a1(3)/a;
   
 meshdiam(1,1:3)=[a,b,c];   
 clear n diamxyz a b c a1 r1;



% tough2 角点网格计算: 共为(X网格数+1)*(Y网格+1)*(Z网格+1)
% 结点编号按X-->Y-->Z依次编号
n=1;
nx_countbigin=1;
m=1;
nx2y=0; 
nxcopy=1;
% X坐标计算
TOUGHcorXYZ{(meshdiam(1,1)+1)*(meshdiam(1,2)+1)*(meshdiam(1,3)+1),4}=0;

while n<=(meshdiam(1,1)-1)*meshdiam(1,2)*meshdiam(1,3) % x direction conne number
%CONNE文件中，网格的X方向连接数，即(X网格数-1) *Y网格*Z网格
   xsmall_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n,1})==1);
   xlarge_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n,2})==1);
    if nx_countbigin==1  %第一个连接时
    TOUGHcorXYZ{m,1}=m; %结点编号，采用数值型
    TOUGHcorXYZ{m,2}=toughxyz{xsmall_meshnum,3}-TOUGHCNNE{n,3}; %tough2 结点P因X方向坐标的变化量
        
    %中间结点
    TOUGHcorXYZ{m+1,1}=m+1; %结点编号，采用数值型
    TOUGHcorXYZ{m+1,2}=toughxyz{xsmall_meshnum,3}+TOUGHCNNE{n,3};    
    m=m+2;    
    end
   
   if nx_countbigin>1 && nx_countbigin<=meshdiam(1,1)-1  %X方向连接数，即X网格-1
    TOUGHcorXYZ{m,1}=m; %结点编号，采用数值型
    TOUGHcorXYZ{m,2}=toughxyz{xsmall_meshnum,3}+TOUGHCNNE{n,3}; %tough2 x 坐标
    m=m+1;    
   end
   if nx_countbigin==meshdiam(1,1)-1
   TOUGHcorXYZ{m,1}=m; %结点编号，采用数值型
   TOUGHcorXYZ{m,2}=toughxyz{xlarge_meshnum,3}+TOUGHCNNE{n,4};
   m=m+1;
   nx2y=nx2y+1; %当遇到X尾单元时，表明进入一下排。
   nx_countbigin=0;  %%通过置0使其重新回归1
   end      
    n=n+1;
   nx_countbigin=nx_countbigin+1;
 
 %判断是否到Y排末  
   if nx2y==meshdiam(1,2)
       while nxcopy<=meshdiam(1,1)+1             
    TOUGHcorXYZ{m,1}=m; %结点编号，采用数值型
    TOUGHcorXYZ{m,2}=TOUGHcorXYZ{m-meshdiam(1,1)-1,2}; 
    m=m+1;
    nxcopy=nxcopy+1;
        end
          nxcopy=1;
          nx2y=0; %Y方向排数计数清零                
   end   
end 


%Z方向最顶一排网格结点坐标采用直接copy
ztopdiam=1;
while ztopdiam<=(meshdiam(1,1)+1)*(meshdiam(1,2)+1)
    TOUGHcorXYZ{m,1}=m; %结点编号，采用数值型
    TOUGHcorXYZ{m,2}=TOUGHcorXYZ{m-(meshdiam(1,1)+1)*(meshdiam(1,2)+1),2}; 
    m=m+1;
    ztopdiam=ztopdiam+1;    
end
clear m n1 ztopdiam
%X方向坐标提取结束

%Y坐标提取 
m=1;
while n<=(meshdiam(1,1)-1)*meshdiam(1,2)*meshdiam(1,3)+...
        meshdiam(1,1)*(meshdiam(1,2)-1)*meshdiam(1,3)
   %CONNE文件中，网格的Y方向连接数，即X网格 *(Y网格-1)*Z网格
   %计算以connect文件为基础，按toughxyz对应的网格。
   ysmall_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n,1})==1);
   ylarge_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n,2})==1);
   
   if nx2y==0  
    if nx_countbigin<=meshdiam(1,1)
    %后边结点采用外推插值 直接用第一结点值加上该值即为外推边界结点压力值
    %边外推值-单元结点 与单元结点与前点的差成比例
    %基准是后点原则，即第1结点以第一单元为基准，修正压力,以次类推
    %最边上的CNNE算出两排，分别为最边上后一排与次后排    
    %下为最后排外推
     TOUGHcorXYZ{m,3}=toughxyz{ysmall_meshnum,4}-TOUGHCNNE{n,3};     
    %下为次后排中间插
    TOUGHcorXYZ{m+(meshdiam(1,1)+1),3}=toughxyz{ysmall_meshnum,4}+TOUGHCNNE{n,3}; 
     m=m+1 ;
     end     
   if nx_countbigin==meshdiam(1,1)
    %后边结点采用外推插值 直接用第一结点值加上该值即为外推边界结点压力值
    %边外推值-单元结点 与单元结点与前点的差成比例
    %基准是后点原则，即第1结点以第一单元为基准，修正压力,以次类推
    %最边上的CNNE算出两排，分别为最边上后一排与次后排
    
    %直接复制右次行结点
     TOUGHcorXYZ{m,3}=TOUGHcorXYZ{m-1,3};
          
    %直接复制右次行结点PT差
    TOUGHcorXYZ{m+(meshdiam(1,1)+1),3}= TOUGHcorXYZ{m+(meshdiam(1,1)+1)-1,3}; %tough2 结点P因Y方向坐标的变化量
    
    m=m+(meshdiam(1,1)+1)+1; 
     
     nx2y=nx2y+1; %当遇到X尾单元时，表明进入一下排。
     nx_countbigin=0; %通过置0使其重新回归1     
   end   
 else   %%当不为第一排时
    if nx_countbigin<=meshdiam(1,1) 
            %如果不是最后一排连接，则中间结点采用中间插值，结点按照前网格，即第三排结点采用第三排单元计算
     TOUGHcorXYZ{m,3}=toughxyz{ysmall_meshnum,4}+TOUGHCNNE{n,3}; %tough2 结点P因Y方向坐标的变化量
      m=m+1;
   end       
    if nx_countbigin==meshdiam(1,1)
     %直接复制右次行结点PT差
     TOUGHcorXYZ{m,3}=TOUGHcorXYZ{m-1,3};     
     nx2y=nx2y+1; %当遇到X尾单元时，表明进入一下排。
     nx_countbigin=0; %通过置0使其重新回归1
     m=m+1;
    end 
 end
 
    if nx2y==meshdiam(1,2)-1 %表示进入Y的最后一排
        nycopy=1;
      while nycopy<=meshdiam(1,1)
   ysmall_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n-meshdiam(1,1)+nycopy,1})==1);
   ylarge_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n-meshdiam(1,1)+nycopy,2})==1);
        
     TOUGHcorXYZ{m,3}=toughxyz{ylarge_meshnum,4}+TOUGHCNNE{n-meshdiam(1,1)+nycopy,4}; %tough2 结点P因Y方向坐标的变化量
     
         m=m+1;      
        if nycopy==meshdiam(1,1) 
           TOUGHcorXYZ{m,3}=TOUGHcorXYZ{m-1,3};
          
          m=m+1;
        end 
        nycopy=nycopy+1;
       end
      nx2y=0;
      nycopy=1;
    end 
     n=n+1;
     nx_countbigin=nx_countbigin+1;
 
end     

%Z方向最顶一排网格结点坐标采用直接copy
ztopdiam=1;
while ztopdiam<=(meshdiam(1,1)+1)*(meshdiam(1,2)+1)
    TOUGHcorXYZ{m,3}=TOUGHcorXYZ{m-(meshdiam(1,1)+1)*(meshdiam(1,2)+1),3}; 
    m=m+1;
    ztopdiam=ztopdiam+1;    
end
clear m n1 ztopdiam

%Z方向坐标提取 
m=1;
nxy2z=1;
while n<=(meshdiam(1,1)-1)*meshdiam(1,2)*meshdiam(1,3)...
       +meshdiam(1,1)*(meshdiam(1,2)-1)*meshdiam(1,3)...
        +meshdiam(1,1)*meshdiam(1,2)*(meshdiam(1,3)-1)
%CONNE文件中，网格的Z方向连接数，即X网格 *Y网格*(Z网格-1)
%计算以connect文件为基础，按toughxyz对应的网格
 zsmall_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n,1})==1);
 zlarge_meshnum=find(strcmp(toughxyz(:,1),TOUGHCNNE{n,2})==1);
 
 if nxy2z==1
    if nx_countbigin<=meshdiam(1,1)
    %下为最后排外推
     TOUGHcorXYZ{m,4}=toughxyz{zsmall_meshnum,5}-TOUGHCNNE{n,3}; %tough2 结点P因Z方向坐标的绝对量
     
    %下为次后排中间插
    TOUGHcorXYZ{m+(meshdiam(1,1)+1)*((meshdiam(1,2)+1)),4}=toughxyz{zsmall_meshnum,5}+TOUGHCNNE{n,3}; %tough2 结点P因Y方向坐标的变化量
    m=m+1;     
     end
   if nx_countbigin==meshdiam(1,1)
    %下为最后排外推
    TOUGHcorXYZ{m,4}=TOUGHcorXYZ{m-1,4}; %tough2 结点P因Z方向坐标的绝对量    
    
    %下为次后排中间插
    TOUGHcorXYZ{m+(meshdiam(1,1)+1)*((meshdiam(1,2)+1)),4}=TOUGHcorXYZ{m+(meshdiam(1,1)+1)*((meshdiam(1,2)+1))-1,4}; %tough2 结点P因Y方向坐标的变化量
       m=m+1;      
       nx2y=nx2y+1; %当遇到X尾单元时，表明进入一下排。
       nx_countbigin=0; %通过置0使其重新回归1
   end   
    %判断是否到Y排末  
   if nx2y==meshdiam(1,2)
       while nxcopy<=meshdiam(1,1)+1             
    TOUGHcorXYZ{m,4}=TOUGHcorXYZ{m-meshdiam(1,1)-1,4};    
    TOUGHcorXYZ{m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1),4}=TOUGHcorXYZ{m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1)-meshdiam(1,1)-1,4};
    m=m+1;
    nxcopy=nxcopy+1;
          end
          nxcopy=1;
          nx2y=0; %Y方向排数计数清零  
          nxy2z=nxy2z+1;
          m=m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1);
   end      
 
elseif nxy2z<meshdiam(1,3)-1 && nxy2z~=1
        if nx_countbigin<=meshdiam(1,1)
    
    %下为次后排中间插
    TOUGHcorXYZ{m,4}=toughxyz{zsmall_meshnum,5}+TOUGHCNNE{n,3}; %tough2 结点P因Y方向坐标的绝对量
    m=m+1;     
     end
   if nx_countbigin==meshdiam(1,1)
    %下为最后排外推
    TOUGHcorXYZ{m,4}=TOUGHcorXYZ{m-1,4}; %tough2 结点P因Z方向坐标的绝对量
          m=m+1;      
       nx2y=nx2y+1; %当遇到X尾单元时，表明进入一下排。
       nx_countbigin=0; %通过置0使其重新回归1
   end   
    %判断是否到Y排末  
   if nx2y==meshdiam(1,2)
       while nxcopy<=meshdiam(1,1)+1             
    TOUGHcorXYZ{m,4}=TOUGHcorXYZ{m-meshdiam(1,1)-1,4};
    m=m+1;
    nxcopy=nxcopy+1;
          end
          nxcopy=1;
          nx2y=0; %Y方向排数计数清零  
          nxy2z=nxy2z+1;
   end  
elseif nxy2z==meshdiam(1,3)-1
        if nx_countbigin<=meshdiam(1,1)
    
    %下为排中间插
    TOUGHcorXYZ{m,4}=toughxyz{zsmall_meshnum,5}+TOUGHCNNE{n,3};
    %下为顶排外插
    TOUGHcorXYZ{m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1),4}=toughxyz{zlarge_meshnum,5}+TOUGHCNNE{n,4}; 
    
    m=m+1; 
     end
   if nx_countbigin==meshdiam(1,1)
    %下为最后排外推
    TOUGHcorXYZ{m,4}=TOUGHcorXYZ{m-1,4}; 
    
    TOUGHcorXYZ{m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1),4}=TOUGHcorXYZ{m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1)-1,4};
    
       m=m+1;      
       nx2y=nx2y+1; %当遇到X尾单元时，表明进入一下排。
       nx_countbigin=0; %通过置0使其重新回归1
   end   
    %判断是否到Y排末  
   if nx2y==meshdiam(1,2)
       while nxcopy<=meshdiam(1,1)+1             
    TOUGHcorXYZ{m,4}=TOUGHcorXYZ{m-meshdiam(1,1)-1,4};    
    TOUGHcorXYZ{m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1),4}=TOUGHcorXYZ{m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1)-meshdiam(1,1)-1,4};
    
     m=m+1;
    nxcopy=nxcopy+1;
          end
          nxcopy=1;
          nx2y=0; %Y方向排数计数清零  
          nxy2z=nxy2z+1;
   end  
end
   nx_countbigin=nx_countbigin+1;
   n=n+1 ; 
end    
  




%tough mesh that consist grid number
n=1;
m=1;
nx2y=0;
while n<=meshdiam(1,1)*meshdiam(1,2)*meshdiam(1,3)
    ToughMESH{n,1}=toughxyz{n,1}; % 单元编号
    if nx_countbigin<=meshdiam(1,1)     
    ToughMESH{n,2}=m; % 单元1号编号
    ToughMESH{n,3}=m+1; % 单元2号编号
    ToughMESH{n,4}=m+meshdiam(1,1)+1; % 单元3号编号
    ToughMESH{n,5}=m+1+meshdiam(1,1)+1; % 单元4号编号
    
    ToughMESH{n,6}=m+(meshdiam(1,1)+1)*(meshdiam(1,2)+1); % 单元5号编号
    ToughMESH{n,7}=m+1+(meshdiam(1,1)+1)*(meshdiam(1,2)+1); % 单元6号编号
    ToughMESH{n,8}=m+meshdiam(1,1)+1+(meshdiam(1,1)+1)*(meshdiam(1,2)+1); % 单元7号编号
    ToughMESH{n,9}=m+1+meshdiam(1,1)+1+(meshdiam(1,1)+1)*(meshdiam(1,2)+1); % 单元8号编号
    m=m+1;    
   end
   if nx_countbigin==meshdiam(1,1)
   m=m+1;   
   nx2y=nx2y+1; %当遇到X尾单元时，表明进入一下排。
   nx_countbigin=0;  %%通过置0使其重新回归1
   end      
    n=n+1;
    nx_countbigin=nx_countbigin+1; 
 %判断是否到Y排末  
   if nx2y==meshdiam(1,2)
       m=m+meshdiam(1,1)+1;
       nx2y=0; %Y方向排数计数清零                
   end   
end
clear m n

%Tough2element Group
    n=1;
    m=1;
   zonename{m}=strtrim(toughxyz{n,2});%删除材料名前后空格，先取第1个单元的材料名，以此开头。
   zonegroup{m,1}=[1]; %第一个单位，归为第1组，以此开始判断。
   n=n+1;
while n<=meshdiam(1,1)*meshdiam(1,2)*meshdiam(1,3)
     %用index=find(strcmp(a,b))，这样的一个函数组合就可以查找到索引。
    %strcmp返回一个元胞同维度大小的逻辑数组，用find找到数组中的非零元素
    a=strcmp(strtrim(toughxyz{n,2}),zonename); %判断下一个材料名在已有的材料组名中位置
    grc=find(a);  %判断属于哪个材料组
    if isempty(grc)==1   %如果不属于现有任何一组，则另外增加一个材料组
        m=m+1;
        zonename{m}=strtrim(toughxyz{n,2});%删除材料名前后空格  
        zonegroup{m,1}=n;   %增加新组后，并将该新单元归为该新建组
    else   
        zonegroup{grc,1}(end+1)=n;  %如果属于现有其中一组，则把单元后增加该单元号进行归组
    end    
      n=n+1;  
end    
   
clear a m n grc nxcopy nx2y nx_countbigin


%reshape grid to flac grid
n=1;
while n<=meshdiam(1,1)*meshdiam(1,2)*meshdiam(1,3)
   intvar5=ToughMESH{n,5};  %tough网格4 实为flac 5点
   intvar4=ToughMESH{n,6}; %tough网格5实为FLAC网4
   intvar6=ToughMESH{n,8}; %tough网格7实为FLAC网6
   FLACGRID{n,1}=ToughMESH{n,1};
   FLACGRID{n,2}=ToughMESH{n,2};%grid1
   FLACGRID{n,3}=ToughMESH{n,3};%grid2
   FLACGRID{n,4}=ToughMESH{n,4};
   FLACGRID{n,5}=intvar4;
   FLACGRID{n,6}=intvar5;   
   FLACGRID{n,7}=intvar6;   
   FLACGRID{n,8}=ToughMESH{n,7};
   FLACGRID{n,9}=ToughMESH{n,9};
   n=n+1;
end
clear n intvar4 intvar5 intvar6

%output flac mesh
delete *.f3grid ;
fid=fopen('tough2flac3d.f3grid','a');
fprintf(fid,'*flac3Dmesh creat from tough2 mesh file,\n*disigned by Qianlin Zhu from CUMT\n');
[~,c]=size(zonename);  %材料分组
n=1;
while n<=c
    fprintf(fid,'%s%d %s %s\n', "*Group",n ,"name:",zonename{1,n});
    n=n+1;
end
fprintf(fid,'*Gridpoints\n');

%gridpoin idex and xyz location
n=1;
while n<=(meshdiam(1,1)+1)*(meshdiam(1,2)+1)*(meshdiam(1,3)+1)
   fprintf(fid,'%1s %8d, %8d, %8d, %8d \n', 'G',n, TOUGHcorXYZ{n,2}, TOUGHcorXYZ{n,3},TOUGHcorXYZ{n,4}) ;
   n=n+1;
end

% zoneid and its 8 gridpoints
n=1;
fprintf(fid,'*ZONES\n');
while n<=(meshdiam(1,1))*(meshdiam(1,2))*(meshdiam(1,3))
   fprintf(fid,'%4s %8d,%8d,%8d,%8d,%8d,%8d,%8d,%8d,%8d \r\n', 'Z B8',n,FLACGRID{n,2},...
       FLACGRID{n,3},FLACGRID{n,4},FLACGRID{n,5},FLACGRID{n,6},...
       FLACGRID{n,7},FLACGRID{n,8},FLACGRID{n,9}) ;
   n=n+1;
end

n=1;
fprintf(fid,'*ZONEGROUPS\n');
while n<=c
    fprintf(fid,'%s%s%s \n', 'ZGROUP "', zonename{1,n},'"');
    fprintf(fid,'%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n', zonegroup{n,1});
    fprintf(fid,'\n ',' ');
    fprintf(fid,'\n ',' ');
    n=n+1;
end
clear c  n;
fclose(fid);
fprintf('\n \n %s\n','OK !!! FLAC3D Mesh is creat secessfully');
toc
pause(10)

