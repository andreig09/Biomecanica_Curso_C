//OpenCV Headers
#include<cv.h>
#include<highgui.h>
//Input-Output
#include<stdio.h>
//Blob Library Headers
#include"cvblob.h"
//#include <cvblob.h>
#include<Windows.h>
//NameSpaces
using namespace cv;
using namespace cvb;
using namespace std;

struct blobsDetectados
{
	CvBlobs blobs;
	IplImage *imgBlobs;
};

struct imgtrack
{
	IplImage *tracking;
	IplImage *BlobsTrack;
	CvBlobs BlobsAnteriores;
};

//Funcion que a partir de una imagen filtrada devuelve los blobs.
//tambien genera la img con blobs y la muestra en una ventana
blobsDetectados	detectarBlobs(IplImage *filtrada){
	
	//inicializar elementos
	blobsDetectados salida;
	CvBlobs blobs; //structure to hold blobs
	double dWidth = cvGetSize(filtrada).width;
    double dHeight = cvGetSize(filtrada).height;
	IplImage *labelImg=cvCreateImage(cvSize(dWidth,dHeight),IPL_DEPTH_LABEL,1);//Image Variable for blobs
	IplImage *ImgBlobs=cvCreateImage(cvSize(dWidth,dHeight),IPL_DEPTH_8U,3);//Image Variable for blobs


	//Finding the blobs
	unsigned int result=cvLabel(filtrada,labelImg,blobs);
	
	int tama�oBlobs = blobs.size();

	if ( tama�oBlobs > 0) //Si se detecta al menos 1 blob, se dibujan en la imagen y se numeran
	{
	//Filtering the blobs (sacar el ruido)
	cvFilterByArea(blobs,500,blobs[cvLargestBlob(blobs)]->area);

	//Rendering the blobs
	cvRenderBlobs(labelImg,blobs,filtrada,ImgBlobs);
	
	////////////////////////////////////////////////////////////////////////////
	//Todo lo que sigue es para que aparezca un n�mero en el centroide
	CvFont font;
    cvInitFont(&font, CV_FONT_HERSHEY_SIMPLEX, 0.4, 0.4, 0, 1, 8);
	CvPoint centroide;
	char buffer[7];
	int itblob = 0;
			
	for (CvBlobs::const_iterator it=blobs.begin(); it!=blobs.end(); ++it)
	{
		itblob++;
		centroide.x = it->second->centroid.x;
		centroide.y = it->second->centroid.y;
		itoa (itblob,buffer,10);
		cvPutText(ImgBlobs,buffer,centroide,&font,cvScalar(0,0,0));
	}
	//////////////////////////////////////////////////////////////////////////////
	}
	
	//Se muestra la imagen
	cvShowImage("Blobs", ImgBlobs);
		
	salida.blobs = blobs;
	salida.imgBlobs = ImgBlobs;
	return salida;
}

double Distance2(double dX0, double dY0, double dX1, double dY1)
{
    return sqrt((dX1 - dX0)*(dX1 - dX0) + (dY1 - dY0)*(dY1 - dY0));
}

//ubica un blob (o el m�s parecido y m�s cercano) de un conjunto de blobs.

//POR AHORA ENCUENTRA SOLO EL MAS CERCANO.
CvBlob ubicarBlob(CvBlob blobanterior, CvBlobs blobs){ 
	
	CvPoint centroideanterior;
	centroideanterior.x = blobanterior.centroid.x;
	centroideanterior.y = blobanterior.centroid.y;
	CvPoint centroide;
	
	CvBlob actual;

	vector< pair<CvLabel, CvBlob*> > blobList;
    copy(blobs.begin(), blobs.end(), back_inserter(blobList));

	actual = *blobList[0].second;
	double distancia;
	double distanciaNueva;
	distancia = Distance2(centroideanterior.x,centroideanterior.y,actual.centroid.x,actual.centroid.y);
	int tama�o = blobList.size();

	for (int i = 0; i < tama�o; i++)
	{
		centroide.x = (*blobList[i].second).centroid.x;
		centroide.y = (*blobList[i].second).centroid.y;
		distanciaNueva = Distance2(centroideanterior.x,centroideanterior.y,centroide.x,centroide.y);
		if (distanciaNueva < distancia )
		{
			actual = (*blobList[i].second);
			distancia = distanciaNueva;
		}
	}

	return actual;

}

imgtrack seguirBlob(IplImage* cuadro,IplImage* filtrada,CvBlob lastBlob,IplImage* imagenTracking){
	
	imgtrack salida;
	CvBlob anterior = lastBlob;
	
	IplImage* imgtracked;
	IplImage* linea = imagenTracking;
	CvPoint lastcentroid;
	lastcentroid.x = anterior.centroid.x;
	lastcentroid.y = anterior.centroid.y;

	blobsDetectados detectar;
	CvBlobs blobs;

	detectar = detectarBlobs(filtrada);
	blobs = detectar.blobs;
	
	if (blobs.size() > 0)
	{
	CvBlob blobActual;
	blobActual  = ubicarBlob(anterior,blobs);
	int posX;
	int posY;
	posX = blobActual.centroid.x;
	posY = blobActual.centroid.y;

	if(lastcentroid.x>=0 && lastcentroid.y>=0 && posX>=0 && posY>=0)
        {
            // Draw a line from the previous point to the current point
            cvLine(linea, cvPoint(posX, posY), cvPoint(lastcentroid.x, lastcentroid.y), cvScalar(0,0,255), 4);
		}

    //anterior = blobActual;
	}
	
	salida.BlobsAnteriores = detectar.blobs;
	imgtracked = cvCreateImage(cvGetSize(cuadro), IPL_DEPTH_8U, 3);
	imgtracked = detectar.imgBlobs;
	cvAdd(imgtracked, linea, imgtracked);
	salida.BlobsTrack = imgtracked;
	salida.tracking = linea;
	return salida;
}
