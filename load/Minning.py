import pandas as pd
import pydotplus
from IPython.display import Image
from sklearn import \
    metrics  # Import scikit-learn metrics module for accuracy calculation
from six import StringIO
from sklearn.model_selection import \
    train_test_split  # Import train_test_split function
from sklearn.tree import \
    DecisionTreeClassifier  # Import Decision Tree Classifier
from sklearn.tree import export_graphviz


def main():
    # col_names = ['Flow ID', 'Source IP', 'Source Port', 'Destination IP', 'Destionation Port', 'Protocol', 'Timestamp', 'Flow Duration', 'Label']
    # load dataset
    pima = pd.read_csv("Friday-WorkingHours-Afternoon-DDos.pcap_ISCX.csv", header=0)
    print("load data success")

    pima.head()

    print(pima.head())
    print("BUILDING!!!!!")
    print(pima.columns)
    # feature_cols = ['Flow ID', 'Source IP', 'Source Port', 'Destination IP', 'Destionation Port', 'Protocol', 'Timestamp', 'Flow Duration']
    y = pima[' Label'] # Target variable

    pima[' Source IP']=pd.Categorical(pd.factorize(pima[' Source IP'])[0])
    pima[' Destination IP']=pd.Categorical(pd.factorize(pima[' Destination IP'])[0])
    pima[' Timestamp']= pd.Categorical(pd.factorize(pima[' Timestamp'])[0])
    pima['Flow ID']= pd.Categorical(pd.factorize(pima['Flow ID'])[0])
    print("trying to convert source IPPPPP", pima[' Source IP'])

    del pima[' Label']
    # del pima['Flow ID']
    # del pima[' Source IP']
    # del pima[' Destination IP']
    # del pima[' Timestamp']
    del pima['External IP']
    del pima['Flow Bytes/s']
    del pima[' Flow Packets/s']
# delete attributes that could not be converted to float since the api is trying to convert all the strings to float for making the decision tree
    X = pima # Features
    

    print("I GOT FEATURES")

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=1) # 70% training and 30% test

    print("START CREATING")

    # Create Decision Tree classifer object
    clf = DecisionTreeClassifier(criterion="gini", max_depth=5)

    
    # Train Decision Tree Classifer
    clf = clf.fit(X_train,y_train)

    #Predict the response for test dataset
    y_pred = clf.predict(X_test)

    print("Accuracy using gini index:",metrics.accuracy_score(y_test, y_pred))

    dot_data = StringIO()
    export_graphviz(clf, out_file=dot_data,  
                    filled=True, rounded=True,
                    special_characters=True,feature_names = pima.columns,class_names=['Benign','Ddos'])
    graph = pydotplus.graph_from_dot_data(dot_data.getvalue())  
    graph.write_png('DM_gini.png')
    Image(graph.create_png())

    clf = DecisionTreeClassifier(criterion="entropy", max_depth=5)

    # Train Decision Tree Classifer
    clf = clf.fit(X_train,y_train)

    #Predict the response for test dataset
    y_pred = clf.predict(X_test)

    print("Accuracy using entropy index:",metrics.accuracy_score(y_test, y_pred))

    dot_data = StringIO()
    export_graphviz(clf, out_file=dot_data,  
                    filled=True, rounded=True,
                    special_characters=True,feature_names = pima.columns,class_names=['Benign','Ddos'])
    graph = pydotplus.graph_from_dot_data(dot_data.getvalue())  
    graph.write_png('DM_entropy.png')
    Image(graph.create_png())

    

if __name__ == "__main__":
    main()
