import numpy as np 
import pylab as pyl
from scipy.misc import imread
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import scipy.ndimage as nd
import statistics as stt

#Esta función me lee la imagen y retorna la matriz de numpy.
def read_image(image, show = False):
    my_image = imread(image, mode = 'L')
    if(show == True):
        plt.imshow(my_image, cmap = 'gray')
        plt.show()
    return my_image


#Esta función me dice si el fondo es blanco o negro.
def background(colorlist):
    sum1 = 0
    sum2 = 0
    for i in range(50):
        sum1 += colorlist[i]
        sum2 += colorlist[255-i]

    if(sum1 > sum2):
        return 'black'
    else:
        return 'white'

#Esta función me binarisa la imagen en blanco y negro.
def black_white(image, show = False):
    colorlist = color_function(image)
    if(background(colorlist) == 'white'):
        imbin = pyl.where(image>200,0,255)
    else:
        imbin = pyl.where(image<50,0,255)
    if(show == True):
        plt.imshow(imbin, cmap='gray')
        plt.show()
    return imbin

#Esta función me dice cuantos pixeles hay de cada color.
def color_function(matrix, number_colors = 256):
    color = [0]*(number_colors)
    for i in range(len(matrix)):
        for j in range(len(matrix[i])):
            color[matrix[i][j]] += 1
    return color

#Esta función me da los labels correctos.
def clean_data(color_list, center_list):
    color_list.pop(0)
    color_list.pop(0)
    center_list.pop(0)
    
    i = 0
    while(i < len(color_list)):
        if(color_list[i] < 100):
            color_list.pop(i)
            center_list.pop(i)
            i -=1
        i += 1


#Esta función me da la aceleración del sistema.
def aceleration(particles, hz, dx):
    a = []
    for i in range(len(particles)-2):
        a.append((particles[i][0] - 2*particles[i+1][0] + particles[i+2][0])*dx*hz*hz)
    return stt.mean(a)


def calc(image, hz, dx):
    my_image = read_image(image)
    imbin = black_white(my_image)
    labels , number_labels = nd.label(imbin)

    centers = []
    for i in range(number_labels):
        centers.append(nd.center_of_mass(imbin, labels, i+1))
        
    contador = color_function(labels, number_labels + 1)

    clean_data(contador, centers)

    return aceleration(centers, hz, dx)
    



