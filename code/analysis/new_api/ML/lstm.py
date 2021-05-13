#%%
# import itertools
from keras.models import Sequential
from keras.layers import Dense, Dropout, LSTM, Embedding
from sklearn import preprocessing
from sklearn.preprocessing import MinMaxScaler, OneHotEncoder
import numpy as np
import keras
import tensorflow as tf
import keras.backend as kb
import itertools
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.metrics import mean_squared_error, accuracy_score, roc_auc_score, roc_curve
from keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
#%%
def sampleMaker_entry(sample, input_size, output_size):
    n_slides = len(sample.index) - (output_size + input_size)+1
    entrada = np.array([np.array(sample[entrada_var].iloc[i:i+input_size]) for i in range(0, n_slides, input_size)])
    return entrada

def sampleMaker_out(sample, input_size, output_size):
    n_slides = len(sample.index) - (output_size + input_size)+1
    saida = [sample[saida_var].iloc[i+input_size:i+input_size+output_size] for i in range(0, n_slides, input_size)]
    return saida

def sampleMaker2(sample, input_size, output_size):
    n_slides = len(sample.index) - (output_size + input_size)+1
    return [sample[saida_var][0] for _ in range(n_slides)]

def splitter(data, group):
    data = list(data.groupby(group))
    data = [data[i][1] for i in range(len(data))]
    return data
#%%
path  = "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis"
train = pd.read_csv(f"{path}/ML/train_producers.csv").drop('track_number', axis = 'columns')
test  = pd.read_csv(f"{path}/ML/test_producers.csv").drop('track_number', axis = 'columns')

#%%
from sklearn import preprocessing
le = preprocessing.LabelEncoder()
le.fit(train['condition'])
le.fit(test['condition'])
train['condition'] = le.transform(train['condition'])
test['condition'] = le.transform(test['condition'])

mm_scaler = MinMaxScaler()
variables = train.select_dtypes(include = "float").columns.values
for i in variables:
    train[i] = mm_scaler.fit_transform(train[i].values.reshape(-1, 1))
    train[i] = train[i]-0.001
    test[i]  = mm_scaler.fit_transform(test[i].values.reshape(-1, 1))
    test[i]  = test[i]-0.001
#%%
train = splitter(train, ["album_id", "condition"])
test = splitter(test, ["album_id", "condition"])

for i in train:
    i.reset_index(drop = True, inplace = True)

for i in test:
    i.reset_index(drop = True, inplace = True)

#%%
entrada_var   = [#'danceability',
                 'energy',
                 'loudness',
                #  'speechiness',
                #  'acousticness',
                #  'instrumentalness',
                #  'liveness',
                 'valence',
                 'tempo',
                #  'loudness_var',
                #  'tempo_var',
                #  '0',
                #  '1',
                #  '2',
                #  '3',
                #  '4',
                #  '5',
                #  '6',
                #  '7',
                #  '8',
                #  '9',
                #  '10',
                #  '11',
                 'valence_cat',
                 'energy_cat',
                 'loudness_cat',
                 'tempo_cat',
                 'valence_o',
                 'energy_o',
                 'loudness_o',
                 'tempo_o']
saida_var     = ['condition']

#%%
entrada_treino = list(map(lambda x : sampleMaker_entry(x, 4, 1), train))
saida_treino   = list(map(lambda x : sampleMaker_out(x, 4, 1), train))

entrada_teste = list(map(lambda x : sampleMaker_entry(x, 4, 1), test))
saida_teste   = list(map(lambda x : sampleMaker_out(x, 4, 1), test))

entrada_treino = np.array(list(itertools.chain.from_iterable(entrada_treino)))
saida_treino   = np.array(list(itertools.chain.from_iterable(saida_treino)))

entrada_teste = np.array(list(itertools.chain.from_iterable(entrada_teste)))
saida_teste   = np.array(list(itertools.chain.from_iterable(saida_teste)))

#%%
model = Sequential()
model.add(LSTM(units = 50, return_sequences = True, activation = 'sigmoid', input_shape = (entrada_treino.shape[1], entrada_treino.shape[2])))
model.add(Dropout(0.3))
model.add(Dense(units = 100, activation='relu'))
model.add(Dropout(0.2))
model.add(LSTM(units = 50, activation='sigmoid'))
model.add(Dropout(0.2))
model.add(Dense(1, activation='sigmoid'))

print ('Compiling...')
model.compile(loss='binary_crossentropy',
              optimizer='Adam',
              metrics=['accuracy'])
print('Compiled.')


# for i in range(len(entrada_treino)):
#     print(entrada_treino[i], saida_treino[i])

# %%
# Fitando modelo
model.fit(entrada_treino, saida_treino, epochs = 1000, batch_size = 10)

#%%
from sklearn.metrics import confusion_matrix
previsores = list(itertools.chain.from_iterable(model.predict_classes(entrada_teste)))
real = list(itertools.chain.from_iterable(list(itertools.chain.from_iterable(saida_teste))))
probs = list(itertools.chain.from_iterable(model.predict_proba(entrada_teste)))

print("Model: ", accuracy_score(previsores, real))
# confusion_matrix(previsores, real)
# %%
