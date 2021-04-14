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
    del pima[' Label']
    X = pima # Features
    

    print("I GOT FEATURES")

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=1) # 70% training and 30% test

    print("START CREATING")

    # Create Decision Tree classifer object
    clf = DecisionTreeClassifier()

    # Train Decision Tree Classifer
    clf = clf.fit(X_train,y_train)

    #Predict the response for test dataset
    y_pred = clf.predict(X_test)

    print("Accuracy:",metrics.accuracy_score(y_test, y_pred))

    ot_data = StringIO()
    export_graphviz(clf, out_file=dot_data,  
                    filled=True, rounded=True,
                    special_characters=True,feature_names = feature_cols,class_names=['0','1'])
    graph = pydotplus.graph_from_dot_data(dot_data.getvalue())  
    graph.write_png('diabetes.png')
    Image(graph.create_png())

    

if __name__ == "__main__":
    main()
