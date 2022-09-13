import os,csv
import numpy as np
from scipy import stats
from re import search, split
import statistics
from a12test import a12

inputFiles = ['YOLOv4_Summary.csv','tiny-yolov3_Summary.csv','tinyYOLOv2_Summary.csv','efficientDetD0_Summary.csv']
#inputFiles = ['YOLOv4_Summary.csv']
outFiles = ['yolov4.csv','yolov3.csv','yolov2.csv','edetd0.csv']
#outFiles1 = ['yolov4_stat.csv','yolov3_stat.csv','yolov2_stat.csv','edetd0_stat.csv']
#outFiles1 = ['yolov4_stat.csv']


allData = {}
detectData = {}
classData = {}
keys = []


def a12toChar(a12value):
    v = 2 *abs(a12value - 0.5)
    c = ''
    if v >= 0.474:
        c = 'L' # large
    elif v >= 0.33:
        c = 'M' # medium
    elif v > 0.147:
        c = 'S' # small
    else:
        c = 'N' # negligible
    if a12value > 0.5:
        return  c + '+'
    else:
        return  c + '-'

def average(lst):
    return str(sum(lst) / len(lst))

def getData(data, i):
    with open(outFiles[i], 'w',newline='') as out:
        header_1 = ["MRx-object detection","MRy-object detection","compositeMR-object detection",
        "MRx-object classification","MRy-object classification","compositeMR-object classification",
        "MRx-object detection_classification","MRy-object detection_classification","compositeMR-object detection_classification"]
        header_x = ["Object Detection-compositeMR:MRx","Object classification-compositeMR:MRx","Object Detection_Classification-compositeMR:MRx"]
        header_y = ["Object Detection-compositeMR:MRy","Object classification-compositeMR:MRy","Object Detection_Classification-compositeMR:MRy"]
        writer = csv.writer(out)
        writer.writerow(["Average Values"])
        writer.writerow(header_1)
        row = []
        avgData = []
        # get average of each column        
        f = lambda x: average(np.array(data[:,x],dtype=float))
        avgData.extend([f(x) for x in range(9)])
        row.extend(avgData)
        writer.writerow(row)

        writer.writerow(["Median values"])
        writer.writerow(header_1)
        row = []
        mdnData = []   
        f = lambda x: statistics.median(np.array(data[:,x],dtype=float))
        mdnData.extend([f(x) for x in range(9)])
        row.extend(mdnData)
        writer.writerow(row)

        writer.writerow(["Shapiro Wilks pvalues"])
        writer.writerow(header_1)
        row = []
        swData = []
        f = lambda x: stats.shapiro(np.array(data[:,x],dtype=float))[1] # get p-value
        swData.extend([f(x) for x in range(9)])
        row.extend(swData)
        writer.writerow(row)


        writer.writerow(["TTest pvalues for MRx"])
        writer.writerow(header_x)
        row = []
        ttData = []
        f = lambda x: stats.ttest_ind(np.array(data[:,(x+2)],dtype=float), np.array(data[:,x],dtype=float)).pvalue
        ttData.extend([f(x) for x in range(0, 9, 3)])
        row.extend(ttData)
        writer.writerow(row)

        writer.writerow(["TTest pvalues for MRy"])
        writer.writerow(header_y)
        row = []
        ttData = []
        f = lambda x: stats.ttest_ind(np.array(data[:,(x+2)],dtype=float), np.array(data[:,(x+1)],dtype=float)).pvalue
        ttData.extend([f(x) for x in range(0, 9, 3)])
        row.extend(ttData)
        writer.writerow(row)        


        writer.writerow(["A12 Test results for MRx"])
        writer.writerow(header_x)
        row = []
        a12Data = []          
        f = lambda x: a12(np.array(data[:,(x+2)],dtype=float), np.array(data[:,x],dtype=float))
        a12Data.extend([f(x) for x in range(0, 9, 3)])
        row.extend(a12Data)
        writer.writerow(row)

        writer.writerow(["A12 Test results for MRy"])
        writer.writerow(header_y)
        row = []
        a12Data = []          
        f = lambda x: a12(np.array(data[:,(x+2)],dtype=float), np.array(data[:,(x+1)],dtype=float))
        a12Data.extend([f(x) for x in range(0, 9, 3)])
        row.extend(a12Data)
        writer.writerow(row)

        writer.writerow(["A12 Test labels for MRx"])
        writer.writerow(header_x)
        row = []
        a12Data = []          
        f = lambda x: a12toChar(a12(np.array(data[:,(x+2)],dtype=float), np.array(data[:,x],dtype=float)))
        a12Data.extend([f(x) for x in range(0, 9, 3)])
        row.extend(a12Data)
        writer.writerow(row)

        writer.writerow(["A12 Test labels for MRy"])
        writer.writerow(header_y)
        row = []
        a12Data = []          
        f = lambda x: a12toChar(a12(np.array(data[:,(x+2)],dtype=float), np.array(data[:,(x+1)],dtype=float)))
        a12Data.extend([f(x) for x in range(0, 9, 3)])
        row.extend(a12Data)
        writer.writerow(row)


def main():
    i = 0
    for dlData in inputFiles:
        print('Eval stats for ' + dlData.split(".")[0])
        data = []
        file = open(dlData)
        csvreader = csv.reader(file)
        header = next(csvreader)                
        for row in csvreader:
            # read in MRx, MRy and CompositeMR data across all datasets for object
            # detection failure rate, object classification failure rate and detection-classification failure rates            
            data.append([row[3],row[4],row[6],row[7],row[8],row[10],row[11],row[12],row[14]])
        file.close()
        print('data size '+ str(len(data)))
        npData = np.array(data)
        getData(npData, i)
        i += 1


def mr_comparison():
    '''
    comparison of mr performance across all 3 eval. metrics
    -oc
    -od
    -ocd
    '''
    i = 0
    for dlData in inputFiles:
        print('Eval stats for ' + dlData.split(".")[0])
        data = []
        file = open(dlData)
        csvreader = csv.reader(file)
        header = next(csvreader)                
        for row in csvreader:
            compositeMr = row[1] + '_'+ row[2] #concatenate composable mrs to name composite mr
            if compositeMr not in allData:
                allData[compositeMr] = []
            # append composite mr data for od, oc and ocd across all datasets
            allData[compositeMr].append([row[6],row[10],row[14]])
        file.close()
        
        #for key, value in allData.items() :
         #   print(key + '  ' + str(len(value)))
        with open(outFiles1[0], 'w',newline='') as out:
            writer = csv.writer(out)
            top = []        
            writer.writerow(["TTest for Object detection"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = stats.ttest_ind(np.array(temp[:,0],dtype=float), np.array(temp1[:,0],dtype=float))[1]
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)

            writer.writerow(["a12 for Object detection"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = a12(np.array(temp[:,0],dtype=float), np.array(temp1[:,0],dtype=float))
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)

            writer.writerow(["a12 Labels for Object detection"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = a12toChar(a12(np.array(temp[:,0],dtype=float), np.array(temp1[:,0],dtype=float)))
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)

            writer.writerow([" "])
            writer.writerow([" "])

            writer.writerow(["TTest for Object classification"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = stats.ttest_ind(np.array(temp[:,1],dtype=float), np.array(temp1[:,1],dtype=float))[1]
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)

            writer.writerow(["a12 for Object classification"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = a12(np.array(temp[:,1],dtype=float), np.array(temp1[:,1],dtype=float))
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)

            writer.writerow(["a12 Labels for Object classification"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = a12toChar(a12(np.array(temp[:,1],dtype=float), np.array(temp1[:,1],dtype=float)))
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)


            writer.writerow([" "])
            writer.writerow([" "])

            writer.writerow(["TTest for Object detection classification"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = stats.ttest_ind(np.array(temp[:,2],dtype=float), np.array(temp1[:,2],dtype=float))[1]
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)

            writer.writerow(["a12 for Object detection classification"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = a12(np.array(temp[:,2],dtype=float), np.array(temp1[:,2],dtype=float))
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)

            writer.writerow(["a12 Labels for Object detection classification"])
            top.append("CompositeMRs")
            top.extend(allData.keys())
            writer.writerow(top)            
            for key in allData:
                resultrow = []
                resultrow.append(key)
                temp = np.array(allData[key])
                for key2 in allData:                    
                    if key != key2:
                        # perform significance test
                        temp1 = np.array(allData[key2])
                        v = a12toChar(a12(np.array(temp[:,2],dtype=float), np.array(temp1[:,2],dtype=float)))
                        resultrow.extend([v])
                    else:
                        resultrow.extend("-")
                writer.writerow(resultrow)


if __name__ == '__main__':
    main() # read data from source dir into data structures
    #mr_comparison()