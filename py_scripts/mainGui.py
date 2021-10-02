from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .productoWidget import ProductoWidget
from .dronWidget import DronWidget
from .seleccionFiltroWidget import SeleccionFiltroWidget
from .visualizarWidget import VisualizarWidget

##El layout base de todo el proyecto
class GuiLayout(QVBoxLayout):
    def __init__(self,widgetParent):
        QVBoxLayout.__init__(self)
        self.widgetParent=widgetParent
        self.seleccionFiltroWidget=SeleccionFiltroWidget()
        self.dronWidget=DronWidget()
        self.productoWidget=ProductoWidget()
        self.button=QPushButton('Imprimir',self.widgetParent)
        self.button.clicked.connect(self.imprimir)

        self.addWidget(self.seleccionFiltroWidget)
        self.addWidget(self.dronWidget)
        self.addWidget(self.productoWidget)

        self.seleccionFiltroWidget.show()
        self.dronWidget.show()
        self.productoWidget.show()
        
        self.addWidget(self.button)

    def imprimir(self,value):##Converge todos los datos de los widgets
        datos=(self.dronWidget.obtenerInfo())
        datos.update(self.productoWidget.obtenerInfo())
        datos.update(self.seleccionFiltroWidget.obtenerInfo())

        self.visualizarWidget=VisualizarWidget(datos) ##Llama el widget encargado de procesar y mostrar los datos
        self.visualizarWidget.show()

    def closeEvent(self, event):
        self.seleccionFiltroWidget.close()
        self.visualizarWidget.close()
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