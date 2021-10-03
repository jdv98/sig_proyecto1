import qgis
from configparser import ConfigParser
from qgis.core import QgsProject,QgsDataSourceUri,QgsVectorLayer,Qgis
import re

class QgisLayer():#Se encarga de cargar las capas en Qgis
    def __init__(self,iface) -> None:
        self.iface=iface

    def sridValida(self):
        srid= qgis.utils.iface.mapCanvas().mapSettings().destinationCrs().authid()
        srid_re=re.search('(?<=:).*',srid).group(0)
        if(srid_re!='3857' and srid_re!='5367'):
            qgis.utils.iface.messageBar().pushMessage("Error", "SRID debe ser 3857 o 5367", level=Qgis.Critical)
            return False    
        else:

            self.uri = QgsDataSourceUri()
            try:
                cp=ConfigParser()#Carga del database.ini
                cp.read(QgsProject.instance().readPath("./")+'/database.ini')
                self.uri.setConnection(cp._sections['postgresql']['host'], 
                        "5432", 
                        cp._sections['postgresql']['database'], 
                        cp._sections['postgresql']['user'], 
                        cp._sections['postgresql']['password'])

                del(srid_re)
                bloque_layer=QgsProject.instance().mapLayersByName("bloques")#Extrae la capa de Qgis
                terrazas_layer=QgsProject.instance().mapLayersByName("terrazas")

                if(len(bloque_layer)==0):
                    self.agregarCapa('bloques')
                elif(bloque_layer[0].crs().authid()!=srid):
                    QgsProject.instance().removeMapLayer(bloque_layer[0].id())
                    self.agregarCapa('bloques')

                if(len(terrazas_layer)==0):
                    self.agregarCapa('terrazas')
                elif(terrazas_layer[0].crs().authid()!=srid):
                    QgsProject.instance().removeMapLayer(terrazas_layer[0].id())
                    self.agregarCapa('terrazas')
                
                del(srid)
                return True
            except:
                qgis.utils.iface.messageBar().pushMessage("Error", "No se pudo conectar a la base de datos", level=Qgis.Critical)
                return False

    def agregarCapa(self,nombre):#Agrega un capa de postgres en qgis
        self.uri.setDataSource('public',nombre,'geom'+re.search('(?<=:).*', self.iface.mapCanvas().mapSettings().destinationCrs().authid()).group(0),'','id')
        vlayer = QgsVectorLayer(self.uri.uri(), nombre,"postgres")
        QgsProject.instance().addMapLayer(vlayer)