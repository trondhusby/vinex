from sklearn.neighbors import NearestNeighbors
import numpy as np

X = np.array([[-1, -1, 150],
              [-2, -1, 200],
              [-3, -2, 40],
              [1, 1, 1234],
              [2, 1, 21],
              [3, 2, 2000]])

nbrs = NearestNeighbors(n_neighbors=3, algorithm='ball_tree').fit(X)
distances, indices = nbrs.kneighbors(X)
indices
