from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *

class SeleccionFiltroLayout(QVBoxLayout):
    def __init__(self,widgetParent):
        QVBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.build()
    
    def build(self): ##Construye todos los widgets y los agrega para mostrarlos
        self.label = QLabel(self.widgetParent)
        self.label.setText("Seleccion del filtro")
        
        self.combo_filtro = QComboBox(self.widgetParent)
        self.combo_filtro.addItems(['Filtro 1','Filtro 2'])
        
        self.addWidget(self.label)
        self.addWidget(self.combo_filtro)
            
    #retorna la informacion del dron seleccionado y su configuracion
    def obtenerInfo(self):
        return {'filtro': self.combo_filtro.currentIndex()+1}