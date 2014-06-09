%clear all
close all
clc


%Voy a intentar graficar imagenes de las camaras blender con los puntos que
%tengo del ground truth


%load('Variables_save/skeleton.mat')
%load('Variables_save/cam.mat')

total_marker = size(cam(1).marker, 2);
total_frame =  size(cam(1).frame, 2);

list_marker =[1:total_marker];%marcadores que se quieren visualizar
last_frame = 1; %ultimo frame a graficar
n_prev =0; %graficar 3 frame anteriores al último
t_label = 1; %con etiquetas nombre (t_label=0) o numero (t_label=1)
n_cam = 2;%camara numero n_cam
radio = 0;%valor del radio de las circunferencias centradas en el último frame de cada marcador ¿valor en pixeles?
res_x = cam(n_cam).M; %resolucion horizontal
res_y = cam(n_cam).N; %resolucion vertical



cam_aux=cam;
y=[];
for j=1:total_marker
    X=cam(n_cam).marker(j).x(1, :); % al final X(k) indica las coordenadas 'y' del marcador j frame k
    Y=cam(n_cam).marker(j).x(2, :); % al final Y(k) indica las coordenadas 'y' del marcador j frame k
    cam_aux(n_cam).marker(j).x(1,:)= (X+1); %Por algún motivo tengo que hacer estas correcciones para que se solapen los marcadores   
    %cam_aux(n_cam).marker(j).x(2,:)=res_y - Y+3.5;
    cam_aux(n_cam).marker(j).x(2,:)=(res_y - Y+0.5);

end

%cam_aux(n_cam).
im=[];
for k=1:last_frame    
    if k<10
        str = sprintf('cam2_000%d.bmp',k);
    else if k<100
        str = sprintf('cam2_00%d.bmp',k);
        else 
          str = sprintf('cam2_0%d.bmp',k);
        end
    end
    im=[im; str];
end

A=imread(im)
for k=last_frame:last_frame
    figure(1), clf, imshow(im(k, :)) %,axis square, %axis([1, res_x, 1, res_y])
     hold on, plotear(cam_aux, n_cam, list_marker, k, n_prev, t_label, radio)
     %hold off
    pause(0.1)
end
%[XX,YY] = meshgrid(0:res_x,0:res_y);
%plot(XX, YY, 'g.')
% imshow(A(1,1,1))%, hold on
%  plot(1.5, 1, 'g*')

