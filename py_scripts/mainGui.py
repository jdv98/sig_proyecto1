from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from .CulProducLayout import CulProduc

class Gui(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
    
    def build(self):
        self.window =  QWidget()
        self.layout =  CulProduc(self)
        self.window.setLayout(self.layout)
        self.window.show()
        self.setCentralWidget(self.window)

    def closeEvent(self, event):
        for i in reversed(range(self.layout.count())): 
            self.layout.itemAt(i).widget().deleteLater()
        self.window.close()
        self.close()

    def showEvent(self,event):
        self.build()