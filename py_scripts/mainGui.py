from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .productoGui import Producto

class Gui(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
    
    def build(self):
        self.window =  QWidget()
        self.layout =  Producto(self)
        self.window.setLayout(self.layout)
        self.window.show()
        self.setCentralWidget(self.window)

    def closeEvent(self, event):
        self.window.close()
        self.close()

    def showEvent(self,event):
        self.build()