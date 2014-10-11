
function cam_segmentacion = main_segmentacion(names, path_vid, type_vid, path_XML, save_segmentation_mat, path_mat)
%Funcion que permite segmentar y junto a la informacion de la calibracion, devolver una estructura cam

%% ENTRADA
% names -----> cell array con los nombres de los marcadores
% path_vid -->string ubicacion de los videos
% type_vid -->string extension de los videos. Ejemplo '*.dvd', siempre escribir '*.' y la extension.
%           Se asume que los nombres de los videos se diferencian
%           unicamente en un numero antes de la extension.
% path_XML -->string ubicacion de los xml de salida
% save_segmentation_mat -->boolean indicando si se desea guardar cam_segmentacion en un archivo .mat
% path_mat -->string ubicacion del .mat de salida
%% SALIDA
% cam_segmentacion -->estructura cam con toda la informacion relevante de la segmentacion y la calibracion

%% ---------
% Author: M.R.
% created the 20/09/2014.

current_dir = pwd;
path_program = [current_dir '/ProgramaC']; %donde residen los programas que efectuan la segmentacion
%Generar una lista con los nombres de los videos en path_vid
list_vid = get_list_files(path_vid, type_vid);

if ~isempty(list_vid) %solo ejecuta segmentación si encuentra videos
%efectuo la segmentacion
disp('__________________________________________________')
disp('Se inicia el proceso de Segmentacion.')
%list_XML = segmentacion(path_vid, type_vid, path_program, path_XML);
segmentacion(path_vid, type_vid, path_program, path_XML);
%disp('La segmentacion ha culminado con exito.')
end

disp('__________________________________________________')
disp('Se inicia el pasaje de archivos .xml a estructuras .mat.')

%Obtener lista de salida con los nombres de los xml generados
list_XML = get_list_files(path_XML, '*.xml'); 
%Ordenar la lista de nombres
list_XML = sort_list(list_XML);

%cargo los archivos xml provenientes de la segmentacion asi como los datos de las camaras Blender
cam_segmentacion = markersXML2mat(names, path_XML, list_XML);
disp('El pasaje a la estructura .mat a culminado.')


%guardo la informacion en caso que se solicite
if  save_segmentation_mat   %¿se tiene activado el checkbox7?
    %path_mat = handles.MatPath; %donde se guardan las estructuras .mat luego de la segmentacion
%     Lab.cam = cam_segmentacion(:);
%     struct2xml(Lab, [path_XML '/cam.xml'])
%     str = ['Se a guardado el resultado de la segmentacion de las camaras en ', path_XML, '/cam.xml'];
     save([path_mat '/cam'], 'cam_segmentacion')
     str = ['Se a guardado el resultado de la segmentacion de las camaras en ', path_mat, '/cam.mat'];
    disp(str)
end

end


function out=get_list_files(path,type)
%Funcion que genera una lista de un tipo especifico de archivos de un determinado directorio
%% ENTRADA:
% path= directorio de los archivos
% type=tipo de archivos, ejemplo *.doc % Siempre escribir “*.�? y la extension
%% SALIDA: 
% out=cell array de strings con los nombres de los archivos en el orden que los devuelve el OS [nx1] 
%% EJEMPLOS
% d='/Seccion_segmentacion'; %busca en esta carpeta
% tipo = '*.dvd' %archivos con extension .dvd
% out=get_list_files(d,tipo)

%% CUERPO DE LA FUNCION

list_dir=dir(fullfile(path,type));
list_dir={list_dir.name}';
%devuelvo la salida
out=list_dir;
end

function list_XML = sort_list(list_XML)
%Funcion que ordena los nombres de list_XML..
%Se supone que los nombres difieren solo en un numero al final
%La idea es pasar en cada nombre su numero a un vector y luego ordenarlo.
%Devolviendo la lista con los nombres ordenados de menor a mayor.

index1 = strfind(list_XML{1}, '1.'); %index-1 indica donde termina el nombre y empiezan los numeros
n_files = length(list_XML); % cantidad de archivos con extensi�n xml
num_in_name = zeros(1, n_files);
for k=1:n_files %la idea es pasar cada numero de un nombre a un vector y luego ordenarlo
    index2 = strfind(list_XML{k}, '.') -1; %indice que indica hasta donde van los numeros finales
    num_in_name(k)=str2double(list_XML{k}(index1:index2)); %guardo el numero de archivo
end
[~, sort_index] = sort(num_in_name);
list_XML = list_XML(sort_index);
end