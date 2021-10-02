from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *

class DronLayout(QVBoxLayout):
    def __init__(self,widgetParent):
        QVBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.build()
    
    def build(self): ##Construye todos los widgets y los agrega para mostrarlos
        self.label = QLabel(self.widgetParent)
        self.label.setText("Dron")
        
        self.combo_dron = self.query_fill_combo_dron(QComboBox(self.widgetParent),'SELECT * FROM drones()')
        self.combo_dron.currentIndexChanged.connect(self.agregarConfiguraciones)
        
        self.combo_config=QComboBox(self.widgetParent)
        
        self.addWidget(self.label)
        self.addWidget(self.combo_dron)
        self.addWidget(self.combo_config)

    ##Llena el combobox del dron y guarda los resultados
    def query_fill_combo_dron(self,combo_box,query : str):
        from .con_db import con_db
        self.result_dron =con_db(query) ## id,duracion_bateria,capacidad_tanque
        combo_box.addItem("")
        try:
            for result in self.result_dron:
                combo_box.addItem("{} - duracion bateria: {} - capacidad tanque: {}".format(result[0],result[1],result[2]))
        except:
            pass
        finally:
            return combo_box

    ##Cuando se cambia de dron elimina las configuraciones anteriores y las remplaza por las del nuevo dron
    def agregarConfiguraciones(self,value):
        self.combo_config.clear()
        if(value==0):
            return
        from .con_db import con_db
        self.result_config =con_db("SELECT * FROM dron_configuraciones( {} )".format(self.result_dron[value-1][0]))  ## id, ancho_cobertura, volumen_descarga, baterias_x_ha
        self.combo_config.addItem("")
        try:
            for result in self.result_config:
                self.combo_config.addItem("{} - ancho cobertura: {} - volumen descarga: {} - baterias x ha: {}".format(result[0],result[1],result[2],result[3]))
        except:
            pass
    
    #retorna la informacion del dron seleccionado y su configuracion
    def obtenerInfo(self):
        if(self.combo_dron.currentIndex()>0 and self.combo_config.currentIndex()>0):
            return {'drone':self.result_dron[self.combo_dron.currentIndex()-1][0],'config_drone':self.result_config[self.combo_config.currentIndex()-1][0] }
        else:
            return None