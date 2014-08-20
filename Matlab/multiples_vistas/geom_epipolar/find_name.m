function index_x = find_name(structure, n_frame, str)
%Funcion que retorna el indice del marcador con nombre igual al parametro 'str' en cada camara
%% ENTRADA
%structure -->estructura cam o skeleton
%n_frame --> nro de frame
%str     --> string con el nombre a buscar

%% SALIDA
%index_x -->la primer fila contiene los indices de marcadores con el nombre str. En el caso de cam la segunda fila contiene la camara correspondiente, 
%           si es una estructura skeleton esta fila se rellena con -1 

%% CUERPO DE LA FUNCION


%veo de que tipo de estructura se trata
structure_name = get_info(structure, 'name'); %string nombre de la estructura
if sum(strfind(structure_name, 'skeleton')) %si se tiene una estructura skeleton
    names = get_info(structure, 'frame', n_frame, 'marker', 'name');%devuelve un cell string con los nombres de todos los marcadores en el frame n_frame de structure
    index_x = find(strcmp(str, names)); %devuelvo los indices de los marcadores que tienen el nombre contenido en str
    index_x = [index_x; -ones(1, length(index_x))]; %ingreso -1's en la segunda fila
else %de lo contrario es una estructura cam
    cam=structure;    
    n_cams = size(cam, 2); %encuentro el numero de camaras, en futuras versiones este parametro debe sacarase de get_info
    index_x = [];%inicializo la salida
    for i=1:n_cams %para todas las camaras
        names = get_info(cam(i), 'frame', n_frame, 'marker', 'name');%devuelve un cell string con los nombres de todos los marcadores en el frame n_frame de structure
        index_aux = find(strcmp(str, names), 1); %devuelvo los indices de los marcadores que tienen el nombre contenido en str
        if ~isempty(index_aux) %en el caso que se encuentre alguna coincidencia se agrega al vector index_x
            index_aux = [index_aux; i*ones(1, length(index_aux))];
            index_x = [index_x, index_aux];
        end
            
    end
end
end


% % Al trabajar con 14 marcadores los mismos se encuentran en el .bvh con los siguientes nombres
% LeftFoot
% LeftLeg
% LeftUpLeg
% 
% RightFoot
% RightLeg
% RightUpLeg
% 
% RightShoulder
% Head
% 
% LHand
% LeftForeArm
% LeftArm
% 
% LHand
% RightForeArm
% RightArm