function [skeleton, X_out, datos] = main_tracking(skeleton, InitFrameTrack, EndFrameTrack, save_tracking_mat, path_mat)
%Funcion que gestiona el tracking en la funcion GUI

%% CUERPO DE LA FUNCION
%obtengo la entrada para el tracking
X = get_frames_of_marker(skeleton, InitFrameTrack, EndFrameTrack);
index_markers = X(5,:);%me quedo con los indices de los marcadores
X = X(1:4, :);%me quedo solo con las coordenadas y el frame respectivo
%efectuo el tracking 
[X_out,datos]=make_tracking(X, Inf);%Se corre dos veces el tracking, la primera es para encontrar el umbral optimo
X_out =clean_tracking(X_out);%Limpieza de puntos 
porcent_tracking = 98;%ESTO HAY QUE DECIDIR SI SALE PARA FUERA O NO, O SEA PARA EL USUARIO
umbral=histograma_tracking(X_out, porcent_tracking);%ACTUALMENTE GRAFICA COSAS PARA DEBUG, QUE SE VAN A PASAR A OTRA PARTE DE LA INTERFAZ
close all%Esto se tiene que sacar en VERSIONES FUTURAS
[X_out,datos]=make_tracking(X, umbral);
X_out =clean_tracking(X_out);%Limpiando puntos


[~,X_out] = recuperar_indices(X,X_out);%coloco los indices de los marcadores de cada columna

%actualizo la informacion de skeleton
skeleton = update_skeleton(skeleton, X_out,  InitFrameTrack, EndFrameTrack);
if save_tracking_mat
    save([path_mat '/skeleton'], 'skeleton')
    str = ['Se a actualizado el resultado del tracking en el esqueleto ', path_mat, '/skeleton.mat'];
    disp(str)
end
end

function skeleton = update_skeleton(skeleton, X_out, init_frame, end_frame)
%Funcion que permite actualizar la informacion de skeleton con la informacion de X proveniente del tracking


%% CUERPO DE LA FUNCION

row_coord = 1:3;
row_frame = 4;
row_path = 5;
row_accel = 6;
row_index = 8;%fila donde se encuentran los indices de los los marcadores en las columnas de X_out

X_ok =  X_out(:,~isnan(X_out(row_accel,:)) );% Nos quedamos con los marcadores que existen en skeleton 
X_nan = X_out(:,isnan(X_out(row_accel,:)) );

%ingreso los nuevos marcadores a la estructura skeleton
% frames = X_out(row_frame, :);
% init_frame = min(frames);
% end_frame = max(frames);
for frame=init_frame:end_frame 
    index_init = length(find(X_ok(row_frame,:)==frame));%encuentro cuantos marcadores que existen realmente estan en el frame
    column = find(X_nan(row_frame,:)==frame);%encuentro los marcadores que fueron agregados en el frame
    if ~isempty(column) %si se tiene algun marcador agregado en el frame        
        index_end = index_init + length(column); %encuentro el ultimo indice necesario para numerar los marcadores de column
        X_nan(8,column) = (index_init + 1):index_end; %le agrego los indices al final de la estructura
        skeleton = set_info(skeleton, 'frame', frame, 'n_markers', index_end);%cambio el numero de marcadores en el frame de skeleton
        skeleton = set_info(skeleton, 'frame', frame, 'marker', X_nan(row_index,column), 'coord', X_nan(row_coord, column)); %agrego las coordenadas del punto
        skeleton = set_info(skeleton, 'frame', frame, 'marker', X_nan(row_index,column), 'name', cellstr(num2str(X_nan(row_index,column)'))); %hago que el nombre sea el indice
        skeleton = set_info(skeleton, 'frame', frame, 'marker', X_nan(row_index,column), 'state', ones(1,length(column)));  %aclaro que su calidad es la de un punto agregado       
    end
end
X_out = [X_ok, X_nan]; %agrupo nuevamente todos los marcadores 
[~, sort_column] = sort(X_out(row_frame, :), 2); %obtengo los indices de columnas ordenadas por frame creciente
X_out = X_out(:,sort_column);
%agrego los indices de los marcadores

n_paths = max(X_out(5,:));%numero total de trayectorias encontradas
skeleton = set_info(skeleton, 'n_paths', n_paths);
for k=1:n_paths
    columns = X_out(row_path, :)==k; %encuentro la trayectoria k
    path_frames = X_out(row_frame,columns);
    end_path_frame = max(path_frames);
    init_path_frame = min(path_frames);
    skeleton = set_info(skeleton, 'path', k, 'name', cellstr(num2str(k))); % setea el nombre asociado a la trayectoria k de structure
    skeleton = set_info(skeleton, 'path', k, 'members', [X_out(row_index,columns) ; path_frames] ); % setea una matriz 2xn_markers. la primer fila son los indices de los marcadores
    %         miembros de la trayectoria k de la estructura structure y la fila 2 son
    %         los correspondientes frames.
    skeleton = set_info(skeleton, 'path', 1, 'state', 0); % setea una medida de calidad para la trayectoria k de la estructura structure
    skeleton = set_info(skeleton, 'path', k, 'n_markers', length(path_frames)); % setea el numero de marcadores totales en la trayectoria k de structure
    skeleton = set_info(skeleton, 'path', k, 'init_frame', init_path_frame); %setea el frame inicial de la trayectoria k de structure
    skeleton = set_info(skeleton, 'path', k, 'end_frame', end_path_frame); %setea  el frame final de la trayectoria k de structure
    
end 


end

function X_out =clean_tracking(X_out)
%Funcion que permite descartar puntos que no pertenecen a ninguna
%trayectoria y truncar trayectorias que se encuentran incompletas.

%% Limpieza de puntos no trackeados
X_out = X_out(:,X_out(7,:)~=0);

%% Limpieza de trayectorias truncas

total_frames = max(X_out(4,:))-min(X_out(4,:));

for n_path=1:max(X_out(5,:))
    if size(X_out(:,X_out(5,:)==n_path),2)<0.9*total_frames
        X_out = X_out(:,X_out(5,:)~=n_path);
    end
end
end