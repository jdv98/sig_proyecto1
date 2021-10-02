from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .visualizarLayout import VisualizarLayout

class VisualizarWidget (QWidget):
    def __init__(self,datos):
        QWidget.__init__(self)
        self.setWindowTitle('Resultados')
        self.datos=datos
        self.build()
    
    def build(self):
        self.layout = VisualizarLayout(self,self.datos)
        self.setLayout(self.layout)