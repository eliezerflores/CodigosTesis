close all
clear all

%Please see "bifurcations_Ph1" for indications. The logic is the same, some
%parameter values are changed here becuase they adapt between phases.

%Determining step size gets tricky in some parameters that their threshold
%span through multiple orders of magnitude. For cases like k16, a threshold
%object with different step sizes can be created.

umbral=([0.001:0.001:0.01, 0.01:0.01:0.1, 0.1:0.1:1, 1:1:10, 10:10:100, 100:100:1000, 1000:1000:10000]);

%This way you end up with a manageable size and decent resolution through
%all orders of magnitudes.

%%

%The only thing you need to modify in this section is changing the object
%umbral to the parameter you're currently working with, in this case, k16.

matriz= NaN(length(umbral),14);

for i = 1:length(umbral)

  k2=3.1062e-07; 
  k4=5.2632e+05;
  k5=1.2026e+03;
  k6=5.8683e+07; 
  k9=3.5277e-09;
  k10=2.5561;
  k13=0.2090;
  k14=1.4750e+03;
  k1=0.00217688531461890;
  k3=0.0116821323710160;
  k8=2.67341167302623;
  k12=1.46921454819336;
  k15=23979612.7030956;
  k16=umbral(i);%19.1664743109897;
  k17=9.23387740720957;

  syms M_t Mf_t T_t Tf_t

dydt1= 0==Mf_t*k6-M_t*(T_t/k16)*k2*(1+Mf_t*k13*k17)-M_t*k1-M_t*T_t*k9;
dydt2= 0==M_t*(1/k16)*T_t*k2*(1+Mf_t*k13*k17)-Mf_t*k3-Mf_t*(T_t*k10+k14)-Mf_t*k5-Mf_t*k13;
dydt3= 0==k8*T_t*(1-T_t/k15)+Mf_t*k13*k16-M_t*(T_t/k16)*k2*(1+Mf_t*k13*k17);
dydt4= 0==k12*Tf_t*(1-Tf_t/(1+k15*Mf_t))+M_t*(1/k16)*T_t*k2*(1+Mf_t*k13*k17)-Mf_t*Tf_t*k4;

equations = [dydt1 dydt2 dydt3 dydt4];
vars=[M_t Mf_t T_t Tf_t];

range = [NaN NaN; NaN NaN;NaN NaN; NaN NaN];
sol = vpasolve(equations, vars, range);


dM=Mf_t*k6-M_t*(T_t/k16)*k2*(1+Mf_t*k13*k17)-M_t*k1-M_t*T_t*k9;
dMf=M_t*(1/k16)*T_t*k2*(1+Mf_t*k13*k17)  -Mf_t*k3-Mf_t*(T_t*k10+k14)-Mf_t*k5-Mf_t*k13;
dT=k8*T_t*(1-T_t/k15)+Mf_t*k13*k16-M_t*(T_t/k16)*k2*(1+Mf_t*k13*k17);
dTf=k12*Tf_t*(1-Tf_t/(1+k15*Mf_t))+M_t*(1/k16)*T_t*k2*(1+Mf_t*k13*k17)-Mf_t*Tf_t*k4;

J=jacobian([dM dMf dT dTf], vars);

stable_positive_real_solution_matrix=[];
counter_stable_positive_real_solution=0;
unstable_positive_real_solution_matrix=[];
counter_unstable_positive_real_solution=0;
counter_unstable_rep_positive_real_solution=0;
sensor=0;

for sol_num=1:1:length(sol.M_t);

if isreal([sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)]);
     if sum(double(([sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)])>=0))==4;
            Jeval=subs(J, vars, [sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)]);
        eigenvals=eig(Jeval);  
           if (sum(double(eigenvals)<0))==4;
           %disp('solution is stable :)');
            stable_positive_real_solution_matrix=[stable_positive_real_solution_matrix; 
          double( [sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)])];
           
           counter_stable_positive_real_solution=counter_stable_positive_real_solution+1;
            
       else
            %disp('solution is unstable :(');
           counter_unstable_positive_real_solution=counter_unstable_positive_real_solution+1;

           if counter_unstable_positive_real_solution>1
            counter_unstable_positive_real_solution=counter_unstable_positive_real_solution-1;
        for ii=1:counter_unstable_positive_real_solution
           
             if (sum(abs(minus(double( [sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)]), ...
                 unstable_positive_real_solution_matrix(ii,:))))<2)
                       counter_unstable_rep_positive_real_solution=counter_unstable_rep_positive_real_solution+1;
                       sensor=sensor+1;
                       break
             end
        end
          if sensor==0
           unstable_positive_real_solution_matrix=[unstable_positive_real_solution_matrix; 
               double( [sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)])];
             counter_unstable_positive_real_solution=counter_unstable_positive_real_solution+1;
          else
              sensor=sensor-sensor;
          end


         else  
         unstable_positive_real_solution_matrix=[unstable_positive_real_solution_matrix; 
          double( [sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)])];
         end

        end
       
           [sol.M_t(sol_num) sol.Mf_t(sol_num) sol.T_t(sol_num) sol.Tf_t(sol_num)];
         
     else
    %disp('solution has negative elements, choose another value');
     end
     
else
    %disp('solution is complex, we move to another value');
end

end
  
 MtotS=sum(stable_positive_real_solution_matrix(:,[1,2]),2);
 TtotS=sum(stable_positive_real_solution_matrix(:,[3,4]),2);

 MtotU=sum(unstable_positive_real_solution_matrix(:,[1,2]),2);
 TtotU=sum(unstable_positive_real_solution_matrix(:,[3,4]),2);

 
matriz(i,1)=umbral(i);
matriz(i,2)=counter_stable_positive_real_solution;
matriz(i,3)=MtotS(1);
matriz(i,4)=TtotS(1);
if counter_stable_positive_real_solution>1
matriz(i,5)=MtotS(2);
matriz(i,6)=TtotS(2);
end

matriz(i,7)=counter_unstable_positive_real_solution;
matriz(i,8)=counter_unstable_rep_positive_real_solution;
matriz(i,9)=MtotU(1);
matriz(i,10)=TtotU(1);
if counter_unstable_positive_real_solution>1
matriz(i,11)=MtotU(2);
matriz(i,12)=TtotU(2);
end
if counter_unstable_positive_real_solution>2
matriz(i,13)=MtotU(3);
matriz(i,14)=TtotU(3);
end

end

