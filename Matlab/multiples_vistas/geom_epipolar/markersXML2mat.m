%function cam = markersXML2mat(n_cams, n_markers, n_frames, names, archivo)
function cam = markersXML2mat(names, path_XML, list_XML)
%Funcion que lleva la informacion de una lista de marcadores desde un XML a la estructura de datos cam.mat 

%% ENTRADA
% n_cams -->numero de camaras, este parametro indica el numero de archivos XML a cargar
% n_markers -->numero de marcadores en el esqueleto 3D
% n_frames --> numero de frames utilizados 
% names    --> cell array con los nombres de los marcadores que se estan ingresando (se utiliza para inicializar las trayectorias)
% archivo -->string que indica la ubicacion del archivo XML asi como su 'prefijo'. Los archivos para distintas camaras de un unico experimento deben diferir
%           en el numero al final del nombre, por ejemplo los archivos de nombre saved_vars/camj.xml con j=1,2,...n_cams indican un unico experimento 
%           que contiene n_cams camaras. Para cargar todas las camaras con esta funcion se debe ingresar archivo =  'saved_vars/cam'
%           

%% SALIDA
% cam --> estructura de datos cam.mat 

%% EJEMPLOS
% clc
% n_cams = 17
% n_markers = 14
% n_frames = 322
% names = {'LeftFoot' 'LeftLeg' 'LeftUpLeg' 'RightFoot' 'RightLeg' 'RightUpLeg'...
%     'RightShoulder' 'Head' 'LHand' 'LeftForeArm' 'LeftArm' 'LHand' 'RightForeArm' 'RightArm'}
% archivo = 'saved_vars/cam'
% cam = markersXML2mat(n_cams, n_markers, n_frames, names, archivo)

%% ---------
% Author: M.R.
% created the 23/08/2014.

%% CUERPO DE LA FUNCION

n_markers = length(names); %nro total de marcadores
n_cams = length(list_XML); %nro de camaras 

for i=1:n_cams %hacer para todas las camaras
    %importo el archivo XML con los datos de interes
    archivo = [path_XML '\' list_XML{i}];%sprintf('%s%d.xml', archivo, i); %genero un string con el nombre del archivo a importar  
    str=['Cargando datos de ', archivo];
    disp(str); %genera un aviso de que se empieza a cargar datos
    [frames_XML, n_frames] = importXML(archivo);  
    
    %relevo informacion del XML asociado a la camara i
    index = str2num([frames_XML(:).name]); %obtengo los indices de los marcadores de cada frame y los ubico consecutivamente en un vector de enteros        
    markers = [frames_XML(:).X]; %obtengo una matriz cuyas columnas son los marcadores de todos los frames
    markers(3,:) = ones(1,length(index)); %dejo los puntos 2D en coordenadas homogeneas normalizadas
    index_frames = find(index==1); %se obtienen los indices donde se cambia de frame        

    if i==1 %inicializo la estructura de salida para todas las camaras acorde a las necesidades        
        [cam, ~]=init_structs(n_markers, n_frames, names);
        str = 'Se ha inicializado una estructura cam';
        disp(str)
    end
    
%     if n_frame ~= n_frame_const %gestionar el error de camaras con distinto nro de frame
%         error('n_frame:InvalidNumFrame',...
%             'El XML %s posee un numero de frames distinto a algun otro XML.\nSe deben ingresar un conjunto de XML con igual numero de frame', list_XML{i})         
%     end
%ingreso los datos de la camara i a la estructura cam.mat
    cam(i) = set_info(cam(i), 'name', i); %ingreso el numero de camara
    %n = length(index_frames);
    n = n_frames;
    for j=1:(n-1) %para cada frame menos el ultimo            
        init_frame = index_frames(j);
        end_frame= index_frames(j+1)-1;
        index_in_frame = index(init_frame:end_frame ); %indices de los marcadores en el frame j
        markers_frame = markers(:,init_frame:end_frame ); %marcadores en el frame j
        cam(i) = set_info(cam(i), 'frame', j, 'marker', index_in_frame, 'coord', markers_frame); %setea con las columnas de "markers" las coordenadas de los marcadores en 'index_frame' del frame j de la camara                    
        cam(i) = set_info(cam(i), 'frame', j, 'n_markers', length(index_in_frame) );%dejo almacenado cuantos marcadores tiene este frame
    end
        index_in_frame = index(index_frames(n):length(index)); %indices de los marcadores en el frame j
        markers_frame = markers(:,index_frames(n):length(index)); %marcadores en el frame j
        cam(i) = set_info(cam(i), 'frame', n, 'marker', index_in_frame, 'coord', markers_frame); %setea con las columnas de "markers" las coordenadas de los marcadores en 'index_frame' del frame j de la camara        
        cam(i) = set_info(cam(i), 'frame', n, 'n_markers', length(index_in_frame) );%dejo almacenado cuantos marcadores tiene este frame
        
        str = sprintf('Se han ingresado los datos en la camara %d\n', i );
        disp(str)
end
end

function [salida, n_frames] = importXML(archivo)
% Funcion que permite importar archivos XML

%% ENTRADA
% archivo --> es un string con la direccion de los archivos a cargar, por ejemplo saved_vars/camj.xml con j=1,2,...n_cams

%% SALIDA
%salida --> estructura de datos con la informacion del XML

%% CUERPO DE LA FUNCION

    xml = xmlread(archivo);    
    children = xml.getChildNodes;    
    Detected_Markers = children.item(0);    
    frames = Detected_Markers.getChildNodes;    
    n_frames = frames.getLength;
    
    k=1;
    for i=0:(n_frames-1)
        if strcmp(frames.item(i).getNodeName, 'Frame')
            salida(k)= parsearFrame(frames.item(i));
            k = k+1;
        end
    end
    n_frames = k-1;%numero total de frames no vacios
end

function frameI = parsearFrame(Frame)
%Puede pasar que un frame no tenga marcadores
    if (Frame.hasChildNodes) && (Frame.getLength > 1)
        k=1;
        markers = Frame.getChildNodes;
        
        totalMarkers = markers.getLength;
        
        for i = 0:(totalMarkers - 1)
            if strcmp(markers.item(i).getNodeName,'Marker')
                %Agregar nombre del marcador a frame.name
                frameI.name(k) = getMarkerName(markers.item(i));
                %Crear matriz de coordenadas
                frameI.X(:,k) = getMarkerPosition(markers.item(i));
                k = k+1;
            end
        end
    else
        %frameI.name = NULL;
        frameI.name = [];
        %frameI.X = NULL;
        frameI.X = [];
    end
end

function name = getMarkerName(Marker)
    name = Marker.getAttribute('id');
end

function xyz = getMarkerPosition(Marker)
    centroid =  Marker.getChildNodes.item(1);
    coordenadas = centroid.getAttributes;
    xyz = [str2num(coordenadas.item(0).getValue.toString); str2num(coordenadas.item(1).getValue.toString); 0];
end



