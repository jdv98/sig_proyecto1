from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .productoLayout import Producto

class ProductoWidget(QWidget):
    def __init__(self):
        QWidget.__init__(self)
        self.layout=Producto(self)
        self.setLayout(self.layout)
        self.setAttribute(Qt.WA_StyledBackground, True)## Agregar colores solo a este widget
        self.setObjectName("productoWidget")
        self.setStyleSheet("QWidget#productoWidget {background-color: Gainsboro;border:2px solid black; }")
    
    def obtenerInfo(self):##Llama el obtenerInfo del producto
        return self.layout.obtenerInfo()