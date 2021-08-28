from datetime import datetime
FORMAT_DATA_TIME = "%d/%m/%Y %H:%M"
FORMAT_DATA = "%d/%m/%Y"

def getDateToStringFormat(date, format):
    return datetime.strptime(date, format)