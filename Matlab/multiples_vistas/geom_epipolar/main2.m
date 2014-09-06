%este script sirve para cargar los datos xml de la segmentacion en estructuras .mat dentro de la carpeta saved_vars

%% Parametros de entrada
names = {'LeftFoot' 'LeftLeg' 'LeftUpLeg' 'RightFoot' 'RightLeg' 'RightUpLeg'...
    'RightShoulder' 'Head' 'LHand' 'LeftForeArm' 'LeftArm' 'RHand' 'RightForeArm' 'RightArm'};
name_bvh ='Mannaquin_con_Armadura_menos_pelotitas.bvh';
%path_XML = 'C:\Users\Administrador\Desktop\Seccion_segmentacion';
path_XML = './Seccion_segmentacion'
archivo = 'cam';


%list_XML = segmentacion(path_vid, type_vid, path_program, path_XML)

%%%%%%%%%%%%%%%%%%%% Esto se tiene que borrar una vez que Andréi solucione lo de los nombres en Source
list_XML=dir(fullfile(path_XML,'*.xml'));
list_XML={list_XML.name}';

index1 = strfind(list_XML{1}, '1.'); %index-1 indica donde termina el nombre y empiezan los numeros
n_files = length(list_XML); % cantidad de archivos con extensi�n xml
num_in_name = zeros(1, n_files);
for k=1:n_files %la idea es pasar cada numero de un nombre a un vector y luego ordenarlo
    index2 = strfind(list_XML{k}, '.') -1; %indice que indica hasta donde van los numeros finales
    num_in_name(k)=str2double(list_XML{k}(index1:index2)); %guardo el numero de archivo
end
[~, sort_index] = sort(num_in_name);
list_XML = list_XML(sort_index);
%%%%%%%%%%%%%%%%%%5

n_cams = length(list_XML); %numero de camaras importadas
n_markers = length(names); %nro de marcadores a detectar

%cargo los archivos xml provenientes de la segmentacion asi como los datos de las camaras Blender
%cam_segmentacion = markersXML2mat(n_cams, n_markers, n_frames, names, archivo)
cam_segmentacion = markersXML2mat(names, path_XML, list_XML);

n_frames = get_info(cam_segmentacion(1), 'n_frames');%obtengo el numero de frames de la camara 1. 
                                                    %(supuestamente todas las camaras deberian tener igual nro de frames). Si esto no ocurre
                                                    %deberia haber algun warning en la terminal matlab producido por markersXML2mat.

%inicializo una estructura skeleton para completar a medida que se trabaje con los datos de cam_segmentacion
[~ , skeleton_segmentacion]=init_structs(n_markers, n_frames, names);
skeleton_segmentacion = set_info(skeleton_segmentacion, 'name_bvh', name_bvh); %setea string nombre de la estructura


%% Reconstruccion



%guardo la informacion
save('saved_vars/cam14_segmentacion', 'cam_segmentacion')
save('saved_vars/skeleton14_segmentacion', 'skeleton_segmentacion')
