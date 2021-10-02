from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .seleccionFiltroLayout import SeleccionFiltroLayout

class SeleccionFiltroWidget(QWidget):
    def __init__(self):
        QWidget.__init__(self)
        self.layout=SeleccionFiltroLayout(self)
        self.setLayout(self.layout)
        self.setAttribute(Qt.WA_StyledBackground, True)## Agregar colores solo a este widget
        self.setObjectName("filtroWidget")
        self.setStyleSheet("QWidget#filtroWidget {background-color: Gainsboro;border:2px solid black; }")
    
    def obtenerInfo(self):##Llama el obtenerInfo del DronLayout
        return self.layout.obtenerInfo()