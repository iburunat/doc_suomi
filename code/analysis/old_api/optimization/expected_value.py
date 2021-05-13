#%%
import math
import itertools
import numpy as np
import matplotlib.pyplot as plt 
############# Explicando o algorítmo

#Brute force for calculating expected value
def seq_2(x):
    bool_seqs = [(x[i] == x[i+1]-1) for i in range(len(x)-1)]
    return np.sum(bool_seqs)


# General method for calculating expected value.
# x and y are constant and recursively updated throughout the code.
def seq(x,y,t):
      if x == t-1:
        hits = (x*y)*(t-1)
        possibilities = math.factorial(t)*(t-1)
        return hits/possibilities
      return seq(x+1, x*y, t)

# Brute force for calculating n sequences for a list of size x
def hits_counter(l_lista):
  hits = []
  lista = list(range(1,l_lista+1))
  perm = list(itertools.permutations(lista))
  for j in range(0, l_lista):
    n_casos = 0
    for i in perm:
      if seq_2(i) == j:
        n_casos = n_casos+1
    hits.append((n_casos, j))
  return hits

#This returns tuples as (n of sequences, n of times it happened throughout all permutations) 
oi = [hits_counter(i) for i in range(3, 7)]



#%%
from math import factorial
def arranjo(n, n_choose):
  return factorial(n)/factorial(n-n_choose)

#%%
n = 6
seq1 = (n-1) / arranjo(n, 2)
q1   = (n-1) / arranjo(n, 2)
q2   = (n-1) / arranjo(n, 2)

t = 2
seq2 =  ( (n-t-1) / arranjo(n-2, 2))  *  (1-q1)  *  (1-q2)
q1 = (n-t-1) / arranjo(n-t, 2)
q2 = (n-t-1) / arranjo(n-t, 2)

t = 3
seq3 = ((n-t-1) / arranjo(n-t, 2)) * (1-q1) * (1-q2)
q1 = (n-t-1) / arranjo(n-t, 2)
q2 = (n-t-1) / arranjo(n-t, 2)

t = 4
seq4 = ((n-t-1) / arranjo(n-t, 2)) * (1-q1) * (1-q2)
q1 = (n-t-1) / arranjo(n-t, 2)
q2 = (n-t-1) / arranjo(n-t, 2)


#%%

a = 1
for i in [seq1, seq2, seq3, seq4]:
  a = a*i
a



#%%

# #Pares
# #Tipo 1:
# n = 6
# transicoes = n-1
# arranjos = arranjo(n, 2)
# prob = [transicoes/arranjos]
# for n in [4, 2]:
# # Tipo 2: n = n-1
#   transicoes = n-1
#   arranjos = arranjo(n, 2)
#   base = transicoes/arranjos
#   cond1 = transicoes/arranjos
#   cond2 = 1/arranjo(n, 2)
#   prob.append(base*(1-cond1)*(1-cond2))
# prob


prob

# %%
n = 6
1 / factorial(n)