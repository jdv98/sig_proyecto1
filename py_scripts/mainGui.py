from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .productoWidget import ProductoWidget
from .dronWidget import DronWidget

class GuiLayout(QVBoxLayout):
    def __init__(self,widgetParent):
        QVBoxLayout.__init__(self)
        self.dronWidget=DronWidget()
        self.productoWidget=ProductoWidget()
        self.button=QPushButton('Imprimir',widgetParent)
        self.button.clicked.connect(self.funcion)

        self.addWidget(self.dronWidget)
        self.addWidget(self.productoWidget)

        self.dronWidget.show()
        self.productoWidget.show()
        
        self.addWidget(self.button)

    def funcion(self,value):
        print(self.dronWidget.obtenerInfo())
        print(self.productoWidget.obtenerInfo())

    def closeEvent(self, event):
        self.dronWidget.close()
        self.productoWidget.close()

class Gui(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
    
    def build(self):
        self.window =  QWidget()
        self.layout =  GuiLayout(self)
        self.window.setLayout(self.layout)
        self.window.show()
        self.setCentralWidget(self.window)

    def closeEvent(self, event):
        self.window.close()
        self.close()

    def showEvent(self,event):
        self.build()