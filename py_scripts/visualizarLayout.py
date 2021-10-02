from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from qgis.core import QgsProject


class VisualizarLayout (QGridLayout):
    def __init__(self,widgetParent,datos):
        QGridLayout.__init__(self)
        self.datos=datos
        self.widgetParent=widgetParent
        self.contador=0
        self.listaLabels=[]
        self.build()

    
    def build(self):
        datos_a_mostrar=[
            'Total de descarga por Ha en litros por hectárea',
            'Total de llenadas de tanque por hectárea',
            'Total litros a descargar por área total en litros',
            'Total de llenadas de tanque por área total',
            'Total de Producto {} ({}) por Tanque en litros por tanque',  #4
            'Total de agua por tanque en litros por tanque',
            'Total de Producto {} ({}) por hectárea en litros por hectárea',  #6
            'Total de Agua por hectárea en litros por hectárea',
            'Total de descarga por hectárea en litros por hectárea',
            'Total de Producto {} ({}) x área total en litros por total de total de hectáreas',   #9
            'Total de Agua por área total en Litros por total de hectáreas',
            'Total de descarga por área total en Litros por total de hectáreas',
            'Area a fumigar'
        ]

        consulta=self.consulta()

        for index_dato in range(0,len(datos_a_mostrar)):
            if(index_dato==4 or index_dato==6 or index_dato==9 ):
                for sub in range(0,len(consulta[index_dato])):
                    self.listaLabels.append(QLabel(datos_a_mostrar[index_dato].format(sub+1,self.datos['Ingredientes'][sub]['Ingrediente']),self.widgetParent))
                    self.listaLabels.append(QLabel(str(consulta[index_dato][sub]),self.widgetParent))
                    self.agregarLabel()
                    
            else:
                self.listaLabels.append(QLabel(datos_a_mostrar[index_dato],self.widgetParent))
                self.listaLabels.append(QLabel(str(consulta[index_dato]),self.widgetParent))
                self.agregarLabel()
 
    def agregarLabel(self):
        if(self.contador%2==0):
            self.listaLabels[-1].setStyleSheet("background-color: Gainsboro;border:2px solid black;")
            self.listaLabels[-2].setStyleSheet("background-color: Gainsboro;border:2px solid black;")
        else:
            self.listaLabels[-1].setStyleSheet("background-color: white;border:2px solid black;")
            self.listaLabels[-2].setStyleSheet("background-color: white;border:2px solid black;")
        self.addWidget(self.listaLabels[-2],self.contador,0)
        self.addWidget(self.listaLabels[-1],self.contador,1)
        self.contador+=1

    def consulta(self):
        from .con_db import con_db
        area=0
        terrazas=QgsProject.instance().mapLayersByName("terrazas")[0].selectedFeatures()
        bloques=QgsProject.instance().mapLayersByName("bloques")[0].selectedFeatures()
        
        if(self.datos['filtro']==1 and len(terrazas)>0):
            area=con_db('SELECT * FROM filtro1(ARRAY[{}])'.format(
                self.agrupa_atrib_capa_comas(terrazas)
                ))[0][0]
        elif(len(terrazas)>0 and len(bloques)>0):
            area=con_db('SELECT * FROM filtro2(ARRAY[{}],ARRAY[{}])'.format(
                self.agrupa_atrib_capa_comas(bloques),
                self.agrupa_atrib_capa_comas(terrazas)
                ))[0][0]
        
        dosis=self.dosis_comas()

        return (con_db("SELECT * FROM calculos_fumigacion({},{},{},ARRAY[{}])".format(
            self.datos['drone'],self.datos['config_drone'],area,dosis
        ))[0])

    def agrupa_atrib_capa_comas(self,capa):
        ids=str(capa[0].attributes()[0])
        for x in range(1,len(capa)):
            ids=ids+','+str(capa[x].attributes()[0])
        return ids

    def dosis_comas(self):
        dosis=''
        for ingrediente in self.datos['Ingredientes']:
            if(dosis==''):
                dosis=ingrediente['dosis']
            else:
                dosis='{},{}'.format(dosis,ingrediente['dosis'])
        return dosis