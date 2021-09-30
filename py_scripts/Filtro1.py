class Window(QMainWindow): 
    def areaSeleccionada(self):
        area=0;
        canvas = qgis.utils.iface.mapCanvas()
        cLayer = canvas.currentLayer()
        selectList = []
        if cLayer:
            selectedList = cLayer.selectedFeatures()
            for f in selectedList:
                area=area+(f.geometry().area())
        return (area)
window = Window()
