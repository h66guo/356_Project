import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeClassifier  
from sklearn.tree import plot_tree  
from sklearn.model_selection import train_test_split  
from sklearn.model_selection import cross_val_score
from sklearn.tree import export_graphviz
from sklearn.metrics import confusion_matrix
from sklearn.metrics import plot_confusion_matrix
import mysql.connector
import csv
from six import StringIO
from IPython.display import Image
import pydotplus


def main():
    username = input("Enter your username\n")
    password = input("Enter your password\n")
    cnx = mysql.connector.connect(username=username,
                            password= password,
                            host='localhost',
                            database='internet_traffic')
    cursor = cnx.cursor(dictionary=True)
    print("Fetching data from database...")
    #query the data we want from the database
    queryString = "select iat_mean, fwd_packets, bwd_packets, duration, label, bytes_per_second, syn_flag_count, rst_flag_count, psh_flag_count, ack_flag_count, urg_flag_count, cwe_flag_count, ece_flag_count, active_time_mean, idle_time_mean  from (((((flow inner join flowbytes on flow.id = flowbytes.flow_id) inner join flowflags on flow.id = flowflags.flow_id) inner join flowiat on flow.id = flowiat.flow_id) inner join flowinfo on flow.id = flowinfo.flow_id) inner join flowpackets on flow.id = flowpackets.flow_id) inner join protocol on flow.protocol_id = protocol.id"
    cursor.execute(queryString)
    rows = []
    for i in cursor: 
        rows.append(i)
    with open('mining.csv', 'w', newline='') as f:
        fieldnames = []
        for i in cursor.column_names:
            fieldnames.append(i)
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print("Data successfully fetched and recorded in csv file...")
    #import the data
    dataframe = pd.read_csv("mining.csv", header=0)
    #used to check if the dataframe loaded the data properly
    dataframe.columns = ['IATMean',
                         'ForwardPackets',
                         'BackwardPackets',
                         'Duration',
                         'Label',
                         'BytesPerSecond',
                         'SYNFlagCount',
                         'RSTFlagCount',
                         'PSHFlagCount',
                         'ACKFlagCount',
                         'URGFlagCount',
                         'CWEFlagCount',
                         'ECEFlagCount',
                         'ActiveTimeMean',
                         'IdleTimeMean']

    #display the data types                     
    print(dataframe.head())
    print(dataframe.dtypes)

    #print unique values for each column
    for columnName in dataframe.columns: 
        print(columnName + ":")
        print(dataframe[columnName].unique())
        dataframe  = dataframe.fillna({columnName: -1})

    #split dataframe into independent and dependent
    X = dataframe.drop('Label', axis=1).copy()
    y = dataframe['Label'].copy()
    
    #build the preliminary clasification tree
    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)
    clf = DecisionTreeClassifier(random_state=42, max_depth=5)
    clf = clf.fit(X_train, y_train)
    # plot the preliminary tree
    dot_data = StringIO()
    export_graphviz(clf,  
                filled=True, rounded=True,
                special_characters=True,feature_names = X.columns,class_names=['BENIGN','DDoS'],out_file=dot_data)
    graph = pydotplus.graph_from_dot_data(dot_data.getvalue())  
    graph.write_png('preliminary.png')
    Image(graph.create_png())

    #create the confusion matrix for the preliminary decision tree
    disp = plot_confusion_matrix(clf, X_test, y_test, display_labels=["BENIGN", "DDoS"])
    plt.show()

    #cost complexity pruning 
    #goal is to find the best pruning parameter alpha which controls how much pruning happens
    path = clf.cost_complexity_pruning_path(X_train, y_train)
    ccp_alphas = path.ccp_alphas
    ccp_alphas = ccp_alphas[:-1]

    clfs = [] #we put decisions trees into here

    print("Cost Complexity Pruning")
    for ccp_alpha in ccp_alphas: 
        print("make tree for alpha")
        clf = DecisionTreeClassifier(random_state=0, ccp_alpha=ccp_alpha, max_depth=5)
        clf = clf.fit(X_train, y_train)
        clfs.append(clf)
    
    train_scores = [clf.score(X_train,y_train) for clf in clfs]
    test_scores = [clf.score(X_test,y_test) for clf in clfs]

    fig, ax = plt.subplots()
    ax.set_xlabel("alpha")
    ax.set_ylabel("Accuracy")
    ax.set_title("Accuracy vs alpha for training and testing sets")
    ax.plot(ccp_alphas, train_scores, marker='o', label="train", drawstyle="steps-post")
    ax.plot(ccp_alphas, test_scores, marker='o', label="test", drawstyle="steps-post")
    ax.legend()
    plt.show()

    
    #there could have been many ways we divide the training and testing dataset 
    #we use 10-fold cross validation to see if we used the best training and testing dataset
    #i.e one set of data may have a different optimal alpha 

    #demonstrate using a single alpha with different data sets 
    #we see that this alpha is sensitive to the datasets 
    print("Cross validation")
    clf = DecisionTreeClassifier(random_state=42, ccp_alpha=0.000005, max_depth=5)
    scores = cross_val_score(clf, X_train, y_train, cv=10)
    df = pd.DataFrame(data={'tree': range(10), 'accuracy': scores})
    df.plot(x='tree', y='accuracy', marker='o', linestyle='--')
    plt.show()

    #use cross validation to find optimal value for ccp_alpha
    alpha_loop_values = []

    print("10-fold for more than one alpha")
    #for each alpha candidate, we run a 10-fold cross validation
    for ccp_alpha in ccp_alphas: 
        clf = DecisionTreeClassifier(random_state=0, ccp_alpha=ccp_alpha, max_depth=5)
        scores = cross_val_score(clf, X_train, y_train, cv=10)
        alpha_loop_values.append([ccp_alpha, np.mean(scores), np.std(scores)])
        print("Finished one alpha candidate")

    #graph the mean and standard deviation of the scores for each candidate alpha 
    alpha_results = pd.DataFrame(alpha_loop_values, columns=['alpha','mean_accuracy', 'std'])

    alpha_results.plot(x='alpha', y='mean_accuracy', yerr='std', marker='o', linestyle='--')
    plt.show()

    #this part is used to find the exact optimal alpha value used to create the optimal pruned classification tree
    print("optimal alpha value")
    optimal_alpha = alpha_results[(alpha_results['alpha'] > 0) & (alpha_results['alpha'] < 0.0001)]
    print(optimal_alpha)

    #optimal pruned tree
    clf = DecisionTreeClassifier(random_state=42, ccp_alpha=2.247936 * (10**(-10)), max_depth=5)
    clf = clf.fit(X_train, y_train)
    dot_data = StringIO()
    export_graphviz(clf,  
                filled=True, rounded=True,
                special_characters=True,feature_names = X.columns,class_names=['BENIGN','DDoS'],out_file=dot_data)
    graph = pydotplus.graph_from_dot_data(dot_data.getvalue())  
    graph.write_png('best.png')
    Image(graph.create_png())

    #draw a confusion matrix for the optimal pruned tree
    disp = plot_confusion_matrix(clf, X_test, y_test, display_labels=["BENIGN", "DDoS"])
    print(disp)
    plt.show()


main()
