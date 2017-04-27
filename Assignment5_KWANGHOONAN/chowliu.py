import os
import math
import numpy as np
import networkx as nx
import matplotlib.pyplot as plt

def get_files():
	rawtrain = open("student_train.data", 'r')
	rawtest = open("student_test.data", 'r')
	train_data = []
	test_data = []

	
	for data in rawtrain:
		train_data.append(list(data.split(',')))

	for data in train_data:
		data[-1] = data[-1].rstrip('\n')
	
	for data in rawtest:
		test_data.append(list(data.split(',')))
	for data in test_data:
		data[-1] = data[-1].rstrip('\n')

	del train_data[-1]
	del test_data[-1]
	train_attr = train_data[0]
	del train_data[0]
	test_attr = test_data[0]
	del test_data[0]
	return train_attr, train_data, test_attr, test_data


def mutual_information(graph):
	m = len(graph[0])
	mu_info_matrix = np.zeros((len(graph), len(graph)))
	G = nx.cycle_graph(len(graph))
	for xi in range(len(graph)):
		for xj in range(xi+1,len(graph)):
			uniqXi = list(set(graph[xi]))
			uniqXj = list(set(graph[xj]))
			I = 0
			for xi_c in uniqXi:
				for xj_c in uniqXj:
					p_xi = graph[xi].count(xi_c)/m
					p_xj = graph[xj].count(xj_c)/m
					indicesXi = [ i for i, x in enumerate((graph[xi])) if x == xi_c]
					indicesXj = [ i for i, x in enumerate((graph[xj])) if x == xj_c]
					p_xixj = len(set(indicesXi) & set(indicesXj)) / m
					if p_xixj > 0:
						I -= p_xixj*math.log(p_xixj/(p_xi*p_xj))
			G.add_edge(xi,xj,weight=I)
			if I is not 0:
				mu_info_matrix[xi,xj] = 1
			
	return G, mu_info_matrix

def getPriors_Counts(data, attr, colNum):
	priors = {}
	justCount = {}
	for col in range(0,colNum):
		uniqVals = list(sorted(set(data[col])))
		uniqDict = {}
		uniqCount = {}
		for uniq in uniqVals:
			prior = data[col].count(uniq) / len(data[col])
			cnt = data[col].count(uniq)
			uniqDict[uniq] = prior
			uniqCount[uniq] = cnt
		priors[attr[col]] = uniqDict
		justCount[attr[col]] = uniqCount
	return priors, justCount


def getCondprobs(data, attr, evidenceCol, queryCol, rowNum):
	condProbs = {}
	uniqEvidence = list(sorted(set(data[evidenceCol])))
	uniqQuery = list(sorted(set(data[queryCol])))
	for evidence in uniqEvidence:
		indxEvidence = [ i for i, x in enumerate(data[evidenceCol]) if x == evidence ]
		for query in uniqQuery:
			indxQuery = [ i for i, x in enumerate(data[queryCol]) if x == query ]
			keys = str(evidence) + "|" + str(query)
			condProbs[keys] = (len(set(indxEvidence)&set(indxQuery))) / len(indxEvidence)
			
	return condProbs
			
if __name__ == "__main__":
	train_attr, train_data,test_attr, test_data = get_files()
	
	colNum = len(train_data[0])
	rowNum = len(train_data)

	transposed_train = (list(map(list,zip(*train_data))))
	train_cls = (transposed_train[-1])
	transposed_test = (list(map(list,zip(*test_data))))
	test_cls = (transposed_test[-1])
	testNum = len(test_cls)

	G, G_ = mutual_information(transposed_train)
	MST=nx.minimum_spanning_tree(G)
	print("Minimum Spanning Tree - Maximum if negative")
	print(sorted(MST.edges(data=True)))
	plt.figure()
	nx.draw_networkx(MST)
	plt.show()

	priors, cnt = getPriors_Counts(transposed_train, train_attr, colNum)
	all_cond = {}

	order = [[14,15],[2,1],[16,17],[15,17],[1,17],[13,17],[11,17],[3,17],[0,17],[12,17],[10,17],[4,17],[6,17],[7,17],[9,17],[17,18],[5,18],[8, 18] ]
	
	#order = [[14,15],[2,1],[16,17],[15,17],[1,17],[13,17],[11,17],[3,17],[0,17],[12,17],[10,17],[4,17],[6,17],[7,17],[9,17],[17,18],[18,5],[18, 8] ]
	for th in order:
		all_cond[ train_attr[th[0]]+ "," + train_attr[th[1]] ] = (getCondprobs(transposed_train, train_attr, th[0], th[1], rowNum))
	#
	uniqCls = list(sorted(set(train_cls)))
	correct = 0.0
	zeroProbs = 0
	for data in test_data:
		#print(data)
		probs = np.ones( (1, len(uniqCls)) )
		for th in order:
			whichCond = train_attr[th[0]] + "," + train_attr[th[1]]
			#print(th)
			if th[1] != 18:
				if str(data[th[0]]) + "|" + str(data[th[1]]) in all_cond[ whichCond ]:
					probs[0][:] *= (all_cond[ whichCond ][ str(data[th[0]]) + "|" + str(data[th[1]]) ])
				else:
					probs[0][:] *= 1
			else:
				for i in range(len(uniqCls)):
					rv =  str(data[th[0]]) + "|" + str(uniqCls[i])
					if rv in all_cond[ whichCond ]:
						probs[0][i] *= (all_cond[ whichCond ][ str( rv ) ])
					else:
						probs[0][i] *= 1

		if max(probs[0]) != min(probs[0]):
			a = probs.tolist()
			predictedCls = a[0].index(max(probs[0][:]))
			if str(predictedCls) == data[-1]:
				correct += 1
		else:
			zeroProbs += 1
	print("How many zero probs ? : ",zeroProbs, "Out of 100")
	print("Accuracy :", correct*100/testNum ,"%")





























