import cython
from scipy.misc import imread
import matplotlib.pyplot as plt
import array
import statistics as stt

#Esta función me lee la imagen y retorna la matriz de numpy.
def read_image(image, show = False):
    my_image = imread(image, mode = 'L')
    if(show == True):
        plt.imshow(my_image, cmap = 'gray')
        plt.show()
    return my_image.astype(int)

#Esta función me dice si el fondo es blanco o negro.
def background(colorlist, limite = 50):
    sum1 = 0
    sum2 = 0
    limit = limite
    #Este for me dice cuantos 'blancos' y 'negros' hay según el límite
    for i in range(50):
        sum1 += colorlist[i]
        sum2 += colorlist[255-i]

    if(sum1 > sum2):
        return 'black'
    else:
        return 'white'

#Esta función me binarisa la imagen en blanco y negro.
def black_white(long[:,:] image, environment, show = False):
    if(environment == 'white'):
        imbin = my_imbin(image,200)
    else:
        imbin = my_imbin(image,50)
    if(show == True):
        plt.imshow(imbin, cmap='gray')
        plt.show()
    return imbin

#Esta función me dice cuantos pixeles hay de cada color.
def color_function(long[:,:] matrix, colors = 256):
    number_colors = colors
    color = [0]*(number_colors)
    ni = matrix.shape[0]
    nj = matrix.shape[1]
    for i in range(ni):
        for j in range(nj):
            color[matrix[i,j]] += 1
    return color

#Esta es una función análoga a pyl.where
def my_imbin(long[:,:]image, limite):
    limit = limite
    ni = image.shape[0]
    nj = image.shape[1]
    for i in range(ni):
        for j in range(nj):
            if(image[i,j] > limit):
                image[i,j] = 255
            else:
                image[i,j] = 0
    return image

#Esta función me define los labels de la image
def my_label(long[:,:] image, framework):
    revisor=array.array('b',[])
    label = 1
    ni = image.shape[0]
    nj = image.shape[1]
    if(framework == 'white'):
     scene = 0
    else:
     scene = 255

    for i in range(ni):
     revisor.append(0)
     for j in range(nj):
      if(image[i,j] == scene):
       image[i,j] = label
       revisor[i] = 1
      else:
       image[i,j] = 0
     if(revisor[i] == 0 and revisor[i-1] == 1):
      label += 1
    return image, label, revisor

#Esta función me sacá los valores del centro de masa de cada label
def my_cm(long[:,:] image, number):
    number_labels = number
    cmx = array.array('d', [0])
    cmy = array.array('d', [0])

    for i in range(number_labels-1):
     cmx.append(0)
     cmy.append(0)

    size = color_function(image, number_labels)
    ni = image.shape[0]
    nj = image.shape[1]
    for i in range(ni):
     for j in range(nj):
      cmx[image[i,j]] += i
      cmy[image[i,j]] += j
      
    for i in range(number_labels):
     cmx[i] = cmx[i]/size[i]
     cmy[i] = cmy[i]/size[i]
     
    return cmx, cmy
      
#Esta función me da los labels correctos.
def clean_data(color_list, centerx, centery):
    for i in range(2):
     color_list.pop(0)
     centerx.pop(0)
     centery.pop(0)
    
    i = 0
    while(i < len(color_list)):
     if(color_list[i] < 100):
      color_list.pop(i)
      centerx.pop(i)
      centery.pop(i)
      i-=1
     i += 1

#Esta función me da la aceleración
def aceleration(particles, hz, dx):
    a = []
    for i in range(len(particles)-2):
     a.append((particles[i] - 2*particles[i+1] + particles[i+2])*dx*hz*hz)
    return stt.mean(a)

def calc(image, hz, dx):
    my_image = read_image(image)
    colorlist = color_function(my_image)
    framework = background(colorlist)
    imbin = black_white(my_image, framework)
    other_imbin, number, revisor = my_label(imbin, framework)
    my_cmx, my_cmy = my_cm(other_imbin,number)
    my_color = color_function(other_imbin, number)
    clean_data(my_color, my_cmx, my_cmy)
    return aceleration(my_cmx, hz, dx)
	
